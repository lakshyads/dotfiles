#!/usr/bin/env bash
# ~/.claude/statusline-command.sh
# Mirrors the Starship prompt style: dir · git branch/status · model · context %

input=$(cat)

# --- Directory (truncate to 3 levels, similar to Starship truncation_length=3) ---
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
home_cwd="${cwd/#$HOME/~}"
# Keep last 3 path components
dir=$(echo "$home_cwd" | awk -F'/' '{ if (NF > 3) { print "…/" $(NF-2) "/" $(NF-1) "/" $NF } else { print $0 } }')

# --- Git branch + dirty flag (skip optional locks to avoid races) ---
branch=""
dirty=""
if git_branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null); then
  branch="$git_branch"
  if [ -n "$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" status --porcelain 2>/dev/null)" ]; then
    dirty="*"
  fi
elif git_tag=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" describe --tags --exact-match HEAD 2>/dev/null); then
  branch="$git_tag"
fi

# --- Claude session data ---
model=$(echo "$input" | jq -r '.model.display_name // empty')
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

# --- Assemble output with ANSI colors (dimmed-friendly) ---
# Cyan for dir, purple for git, green for model, yellow for context
printf "\033[36m%s\033[0m" "$dir"

if [ -n "$branch" ]; then
  printf " \033[35m %s%s\033[0m" "$branch" "$dirty"
fi

if [ -n "$model" ]; then
  printf " \033[32m%s\033[0m" "$model"
fi

if [ -n "$remaining" ]; then
  printf " \033[33mctx:%s%%\033[0m" "$(printf '%.0f' "$remaining")"
fi
