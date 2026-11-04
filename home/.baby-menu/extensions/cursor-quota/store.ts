export type PoolWindow = {
  id: "cursor_models" | "other_models" | "grok_bot";
  label: string;
  percentUsed: number;
  resetAt?: string;
};

export type OnDemandUsage = {
  usedCents: number;
  limitCents: number;
  percentUsed: number;
};

export type CursorQuotaSnapshot = {
  source: "api";
  plan?: string;
  windows: PoolWindow[];
  onDemand?: OnDemandUsage;
  resetAt?: string;
  refreshedAt: string;
  stale: boolean;
};

export type QuotaResult =
  | { ok: true; data: CursorQuotaSnapshot }
  | { ok: false; error: string; sourceTried: string[] };

type Listener = () => void;

let cachedResult: QuotaResult | undefined;
let inFlight: Promise<QuotaResult> | undefined;
const listeners = new Set<Listener>();

export function getCachedQuota(): QuotaResult | undefined {
  return cachedResult;
}

export function subscribeQuota(listener: Listener): () => void {
  listeners.add(listener);
  return () => listeners.delete(listener);
}

export function fetchQuota(): Promise<QuotaResult> {
  if (inFlight) return inFlight;
  inFlight = window
    .babyMenu!.capabilities.invoke<QuotaResult>("cursor-quota", "getQuota")
    .then((result) => {
      cachedResult = result;
      listeners.forEach((listener) => listener());
      return result;
    })
    .finally(() => {
      inFlight = undefined;
    });
  return inFlight;
}

export function toneForRemaining(percentRemaining: number): "live" | "warn" | "danger" {
  if (percentRemaining <= 10) return "danger";
  if (percentRemaining <= 30) return "warn";
  return "live";
}

export function formatUsd(cents: number): string {
  return `$${(cents / 100).toFixed(2)}`;
}

export function formatResetAt(resetAt?: string): string | undefined {
  if (!resetAt) return undefined;
  const ms = Date.parse(resetAt);
  if (Number.isNaN(ms)) return undefined;
  return new Intl.DateTimeFormat(undefined, {
    month: "short",
    day: "numeric",
    hour: "numeric",
    minute: "2-digit",
  }).format(new Date(ms));
}
