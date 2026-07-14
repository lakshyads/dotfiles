#!/bin/bash
# Claude Code status line: model + effort, context remaining %, 5h/7d rate limit usage + time-to-reset
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name')
effort=$(echo "$input" | jq -r '.effort.level // empty')
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')

remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

# Format a token count compactly, e.g. 200000 -> 200k, 1000000 -> 1M
format_ctx_size() {
  local size="$1"
  [ -z "$size" ] && return
  if [ "$size" -ge 1000000 ]; then
    awk -v n="$size" 'BEGIN { v = n / 1000000; printf (v == int(v)) ? "%dM" : "%.1fM", v }'
  elif [ "$size" -ge 1000 ]; then
    awk -v n="$size" 'BEGIN { v = n / 1000; printf (v == int(v)) ? "%dk" : "%.1fk", v }'
  else
    printf "%s" "$size"
  fi
}

ctx_size_fmt=$(format_ctx_size "$ctx_size")

five=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
five_resets_at=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
week_resets_at=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

# Format seconds-until-reset as -Xd / -Xh / -Xm
format_time_left() {
  local resets_at="$1"
  [ -z "$resets_at" ] && return
  local now
  now=$(date +%s)
  local diff=$((resets_at - now))
  [ "$diff" -lt 0 ] && diff=0
  local days=$((diff / 86400))
  local hours=$((diff / 3600))
  local mins=$(((diff % 3600) / 60))
  if [ "$days" -ge 1 ]; then
    printf -- "-%dd" "$days"
  elif [ "$hours" -ge 1 ]; then
    printf -- "-%dh" "$hours"
  else
    printf -- "-%dm" "$mins"
  fi
}

# Colors (dimmed, ANSI)
DIM='\033[2m'
RESET='\033[0m'
CYAN='\033[2;36m'
YELLOW='\033[2;33m'
MAGENTA='\033[2;35m'

parts=()

if [ -n "$effort" ] && [ -n "$ctx_size_fmt" ]; then
  parts+=("$(printf "${CYAN}%s${RESET} ${DIM}%s %s${RESET}" "$model" "$effort" "$ctx_size_fmt")")
elif [ -n "$effort" ]; then
  parts+=("$(printf "${CYAN}%s${RESET} ${DIM}%s${RESET}" "$model" "$effort")")
elif [ -n "$ctx_size_fmt" ]; then
  parts+=("$(printf "${CYAN}%s${RESET} ${DIM}%s${RESET}" "$model" "$ctx_size_fmt")")
else
  parts+=("$(printf "${CYAN}%s${RESET}" "$model")")
fi

if [ -n "$remaining" ]; then
  parts+=("$(printf "${YELLOW}ctx %.0f%% left${RESET}" "$remaining")")
fi

if [ -n "$five" ] || [ -n "$week" ]; then
  usage=""
  if [ -n "$five" ]; then
    five_left=$(format_time_left "$five_resets_at")
    usage="5h $(printf '%.0f' "$five")%"
    [ -n "$five_left" ] && usage="$usage $five_left"
  fi
  if [ -n "$week" ]; then
    week_left=$(format_time_left "$week_resets_at")
    weekstr="7d $(printf '%.0f' "$week")%"
    [ -n "$week_left" ] && weekstr="$weekstr $week_left"
    if [ -n "$usage" ]; then usage="$usage | $weekstr"; else usage="$weekstr"; fi
  fi
  parts+=("$(printf "${MAGENTA}%s${RESET}" "$usage")")
fi

out=""
for p in "${parts[@]}"; do
  if [ -z "$out" ]; then
    out="$p"
  else
    out="$out ${DIM}|${RESET} $p"
  fi
done
printf "%b\n" "$out"
