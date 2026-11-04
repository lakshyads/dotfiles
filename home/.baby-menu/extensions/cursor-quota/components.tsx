import { useEffect, useState } from "react";
import { Badge, Progress, Skeleton, StatusDot } from "@babymenu/ui";
import {
  fetchQuota,
  formatResetAt,
  formatUsd,
  getCachedQuota,
  subscribeQuota,
  toneForRemaining,
  type CursorQuotaSnapshot,
  type OnDemandUsage,
  type PoolWindow,
  type QuotaResult,
} from "./store";

const toneTextClass: Record<"live" | "warn" | "danger" | "muted", string> = {
  live: "text-signal-live",
  warn: "text-signal-warn",
  danger: "text-signal-danger",
  muted: "text-ink-soft",
};

function Header({ tone, label }: { tone: "live" | "warn" | "danger" | "muted"; label: string }) {
  return (
    <div className="flex items-center justify-between text-xxs uppercase tracking-caps text-ink-label">
      <span>cursor · monthly</span>
      <span className={`flex items-center gap-1.5 ${toneTextClass[tone]}`}>
        <StatusDot tone={tone} pulse={tone === "live"} />
        {label}
      </span>
    </div>
  );
}

function UsageTile({
  title,
  percentUsed,
  resetAt,
  detail,
}: {
  title: string;
  percentUsed: number;
  resetAt?: string;
  detail?: string;
}) {
  const reset = formatResetAt(resetAt);
  const tone = toneForRemaining(100 - percentUsed);
  return (
    <div className="flex flex-1 flex-col gap-1.5 rounded-sm bg-elevated px-2.5 py-2">
      <span className="text-xxs uppercase tracking-caps text-ink-label">{title}</span>
      <span className={`text-lg font-light tracking-value ${toneTextClass[tone]}`}>
        {percentUsed.toFixed(1)}
        <span className="ml-0.5 text-xs text-ink-soft">% used</span>
      </span>
      <Progress value={percentUsed} tone={tone} />
      {detail ? <span className="text-xxs text-ink-soft">{detail}</span> : null}
      {reset ? <span className="text-xxs text-ink-soft">resets {reset}</span> : null}
    </div>
  );
}

function OnDemandTile({ onDemand, resetAt }: { onDemand: OnDemandUsage; resetAt?: string }) {
  return (
    <UsageTile
      title="on-demand"
      percentUsed={onDemand.percentUsed}
      resetAt={resetAt}
      detail={`${formatUsd(onDemand.usedCents)} of ${formatUsd(onDemand.limitCents)} limit`}
    />
  );
}

function PoolTile({ item }: { item: PoolWindow }) {
  return <UsageTile title={item.label} percentUsed={item.percentUsed} resetAt={item.resetAt} />;
}

function pool(snapshot: CursorQuotaSnapshot, id: PoolWindow["id"]): PoolWindow | undefined {
  return snapshot.windows.find((w) => w.id === id);
}

export function CursorQuotaView() {
  const [result, setResult] = useState<QuotaResult | undefined>(getCachedQuota());

  useEffect(() => {
    const unsubscribe = subscribeQuota(() => setResult(getCachedQuota()));
    if (!getCachedQuota()) void fetchQuota();
    return unsubscribe;
  }, []);

  if (!result) {
    return (
      <div className="flex flex-col gap-2">
        <Header tone="muted" label="loading" />
        <Skeleton className="h-10 w-full" />
      </div>
    );
  }

  if (!result.ok) {
    return (
      <div className="flex flex-col gap-2">
        <Header tone="danger" label="error" />
        <span className="text-sm text-ink">{result.error}</span>
      </div>
    );
  }

  const { data } = result;
  const cursorModels = pool(data, "cursor_models");
  const otherModels = pool(data, "other_models");
  const grokBot = pool(data, "grok_bot");

  return (
    <div className="flex flex-col gap-2.5">
      <Header tone={data.stale ? "muted" : "live"} label={data.stale ? "stale" : "live"} />
      {data.plan ? (
        <div>
          <Badge tone="neutral">{data.plan}</Badge>
        </div>
      ) : null}
      <div className="flex gap-2">
        {cursorModels ? <PoolTile item={cursorModels} /> : null}
        {otherModels ? <PoolTile item={otherModels} /> : null}
      </div>
      <div className="flex gap-2">
        {grokBot ? <PoolTile item={grokBot} /> : null}
        {data.onDemand ? <OnDemandTile onDemand={data.onDemand} resetAt={data.resetAt} /> : null}
      </div>
    </div>
  );
}
