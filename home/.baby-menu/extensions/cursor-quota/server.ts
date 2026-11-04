import { execFile } from "node:child_process";
import type { BabyMenuServerContext } from "@babymenu/contracts";

type PoolId = "cursor_models" | "other_models" | "grok_bot";

type PoolWindow = {
  id: PoolId;
  label: string;
  percentUsed: number;
  resetAt?: string;
};

type OnDemandUsage = {
  usedCents: number;
  limitCents: number;
  percentUsed: number;
};

type CursorQuotaSnapshot = {
  source: "api";
  plan?: string;
  windows: PoolWindow[];
  onDemand?: OnDemandUsage;
  resetAt?: string;
  refreshedAt: string;
  stale: boolean;
};

type QuotaResult<T> = { ok: true; data: T } | { ok: false; error: string; sourceTried: string[] };

// Cursor keeps a working bearer token in the macOS Keychain; the copy in state.vscdb is encrypted.
const KEYCHAIN_SERVICE = "cursor-access-token";
const KEYCHAIN_ACCOUNT = "cursor-user";

function readToken(): Promise<string | undefined> {
  return new Promise((resolve) => {
    execFile(
      "/usr/bin/security",
      ["find-generic-password", "-s", KEYCHAIN_SERVICE, "-a", KEYCHAIN_ACCOUNT, "-w"],
      { timeout: 5_000 },
      (error, stdout) => {
        const token = stdout.trim();
        resolve(error || !token ? undefined : token);
      },
    );
  });
}

async function callDashboard(
  path: string,
  token: string,
): Promise<{ status: number; body?: Record<string, unknown> }> {
  const res = await fetch(`https://api2.cursor.sh/aiserver.v1.DashboardService/${path}`, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${token}`,
      "content-type": "application/json",
      "connect-protocol-version": "1",
    },
    body: "{}",
    signal: AbortSignal.timeout(15_000),
  });
  if (!res.ok) return { status: res.status };
  return { status: res.status, body: (await res.json()) as Record<string, unknown> };
}

function parseResetAt(epochMs: unknown): string | undefined {
  if (typeof epochMs !== "string" && typeof epochMs !== "number") return undefined;
  const ms = Number(epochMs);
  if (!Number.isFinite(ms) || ms <= 0) return undefined;
  const date = new Date(ms);
  return Number.isNaN(date.getTime()) ? undefined : date.toISOString();
}

function finite(value: unknown): number | undefined {
  return typeof value === "number" && Number.isFinite(value) ? value : undefined;
}

function clampPercent(value: unknown): number | undefined {
  const n = finite(value);
  return n === undefined ? undefined : Math.min(100, Math.max(0, n));
}

// On-demand is usage billed past the included plan, capped by the user's spend limit (cents).
// The API omits individualUsed when nothing is spent, so derive it from limit - remaining.
function normalizeOnDemand(body: Record<string, unknown>): OnDemandUsage | undefined {
  const spend = body.spendLimitUsage as Record<string, unknown> | undefined;
  const limitCents = finite(spend?.individualLimit);
  if (!limitCents || limitCents <= 0) return undefined;
  const remaining = finite(spend?.individualRemaining);
  const usedCents = finite(spend?.individualUsed) ?? (remaining !== undefined ? limitCents - remaining : undefined);
  if (usedCents === undefined) return undefined;
  const clampedUsed = Math.max(0, usedCents);
  return {
    usedCents: clampedUsed,
    limitCents,
    percentUsed: Math.min(100, (clampedUsed / limitCents) * 100),
  };
}

// Grok Bot has its own weekly allowance, reported by GetSandUsageStatus (usagePercent is 0-100, used).
function normalizeGrokBot(body: Record<string, unknown> | undefined): PoolWindow | undefined {
  const percentUsed = clampPercent(body?.usagePercent);
  if (percentUsed === undefined) return undefined;
  const resetMs = typeof body?.nextResetTimestampUtc === "string" ? Date.parse(body.nextResetTimestampUtc) : NaN;
  return {
    id: "grok_bot",
    label: "grok bot",
    percentUsed,
    resetAt: Number.isNaN(resetMs) ? undefined : new Date(resetMs).toISOString(),
  };
}

function normalize(
  body: Record<string, unknown>,
  plan: string | undefined,
  grokBot: PoolWindow | undefined,
): CursorQuotaSnapshot {
  const planUsage = body.planUsage as Record<string, unknown> | undefined;
  const resetAt = parseResetAt(body.billingCycleEnd);
  const windows: PoolWindow[] = [];
  const specs: Array<{ id: PoolId; label: string; field: string }> = [
    { id: "cursor_models", label: "cursor models", field: "autoPercentUsed" },
    { id: "other_models", label: "other models", field: "apiPercentUsed" },
  ];
  for (const spec of specs) {
    const percentUsed = clampPercent(planUsage?.[spec.field]);
    if (percentUsed === undefined) continue;
    windows.push({ id: spec.id, label: spec.label, percentUsed, resetAt });
  }
  if (grokBot) windows.push(grokBot);
  return {
    source: "api",
    plan,
    windows,
    onDemand: normalizeOnDemand(body),
    resetAt,
    refreshedAt: new Date().toISOString(),
    stale: false,
  };
}

function ensureSnapshotTable(context: BabyMenuServerContext) {
  context.db.exec(
    "CREATE TABLE IF NOT EXISTS cursor_quota_snapshot (id INTEGER PRIMARY KEY CHECK (id = 1), snapshot_json TEXT NOT NULL, updated_at INTEGER NOT NULL)",
  );
}

function persistSnapshot(context: BabyMenuServerContext, snapshot: CursorQuotaSnapshot) {
  ensureSnapshotTable(context);
  context.db.run(
    "INSERT INTO cursor_quota_snapshot (id, snapshot_json, updated_at) VALUES (1, ?, ?) ON CONFLICT(id) DO UPDATE SET snapshot_json = excluded.snapshot_json, updated_at = excluded.updated_at",
    [JSON.stringify(snapshot), Date.now()],
  );
}

function readStale(context: BabyMenuServerContext): CursorQuotaSnapshot | undefined {
  ensureSnapshotTable(context);
  const row = context.db.get<{ snapshot_json: string }>("SELECT snapshot_json FROM cursor_quota_snapshot WHERE id = 1");
  if (!row) return undefined;
  try {
    return { ...(JSON.parse(row.snapshot_json) as CursorQuotaSnapshot), stale: true };
  } catch {
    return undefined;
  }
}

export const actions = {
  getQuota: async (
    _input: unknown,
    context: BabyMenuServerContext,
  ): Promise<QuotaResult<CursorQuotaSnapshot>> => {
    const sourceTried = ["keychain"];
    const unavailable = (): QuotaResult<CursorQuotaSnapshot> => {
      const stale = readStale(context);
      return stale
        ? { ok: true, data: stale }
        : { ok: false, error: "Cursor quota unavailable", sourceTried };
    };

    const token = await readToken();
    if (!token) return { ok: false, error: "Cursor sign-in required", sourceTried };

    sourceTried.push("dashboard-api");
    let usage: { status: number; body?: Record<string, unknown> };
    try {
      usage = await callDashboard("GetCurrentPeriodUsage", token);
    } catch {
      return unavailable();
    }
    if (usage.status === 401 || usage.status === 403) {
      return { ok: false, error: "Cursor sign-in required", sourceTried };
    }
    if (usage.status !== 200 || !usage.body) return unavailable();

    let plan: string | undefined;
    try {
      const info = await callDashboard("GetPlanInfo", token);
      const planInfo = info.body?.planInfo as Record<string, unknown> | undefined;
      if (typeof planInfo?.planName === "string") plan = planInfo.planName;
    } catch {
      // optional call
    }

    let grokBot: PoolWindow | undefined;
    try {
      grokBot = normalizeGrokBot((await callDashboard("GetSandUsageStatus", token)).body);
    } catch {
      // optional call
    }

    const snapshot = normalize(usage.body, plan, grokBot);
    if (snapshot.windows.length === 0 && !snapshot.onDemand) return unavailable();
    persistSnapshot(context, snapshot);
    return { ok: true, data: snapshot };
  },
};
