#!/usr/bin/env bash
# agent-skills.sh: install third-party agent skills declared in home/agent-skills.txt.
#
# Usage:
#   ./agent-skills.sh          # sync: install missing skills (bootstrap.sh, rebuild.sh)
#   ./agent-skills.sh update   # `npx skills update -g`, then sync (update.sh)
#   ./agent-skills.sh check    # report only; exit 1 if anything is missing (verify.sh)
#
# Skills land in ~/.agents/skills with a symlink in ~/.claude/skills, and
# `npx skills` records them in ~/.agents/.skill-lock.json, so an on-the-spot
# `npx skills add ... -g` or `npx skills update -g` converges with this.
# The repo's own skills (home/skills/) are linked by home.nix, not here.

set -uo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIST="$DOTFILES_DIR/home/agent-skills.txt"
MODE="${1:-sync}"

export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

if [[ -t 1 ]]; then
  G=$'\033[0;32m' Y=$'\033[0;33m' B=$'\033[0;34m' R=$'\033[0m'
else
  G='' Y='' B='' R=''
fi
info()  { printf "${B}  →  ${R}%s\n" "$*"; }
done_() { printf "${G}  ✓  ${R}%s\n" "$*"; }
warn()  { printf "${Y}  !  ${R}%s\n" "$*" >&2; }

case "$MODE" in
  sync|update|check) ;;
  *) echo "usage: $0 [sync|update|check]" >&2; exit 2 ;;
esac

if ! command -v npx >/dev/null 2>&1; then
  warn "npx not found; install Node via asdf first (./bootstrap.sh)"
  exit 1
fi

# -g with a home-directory cwd keeps `npx skills` from picking project scope.
cd "$HOME" || exit 1

skills() { npx -y skills "$@" </dev/null; }

status=0
if [[ "$MODE" == update ]]; then
  info "Updating installed skills …"
  skills update -g -y >/dev/null || { warn "npx skills update failed"; status=1; }
fi

installed() { [[ -f "$HOME/.agents/skills/$1/SKILL.md" && -e "$HOME/.claude/skills/$1" ]]; }

while read -r source name _; do
  [[ -z "${source:-}" || "$source" == \#* ]] && continue
  if installed "$name"; then
    done_ "$name"
  elif [[ "$MODE" == check ]]; then
    warn "$name: not installed"; status=1
  else
    info "Installing $name from $source …"
    # codex installs into ~/.agents/skills, which Cursor, OpenCode, and Pi also
    # read; claude-code adds the ~/.claude/skills symlink.
    if skills add "$source" --skill "$name" -g -a codex claude-code -y >/dev/null && installed "$name"; then
      done_ "$name"
    else
      warn "$name install failed"; status=1
    fi
  fi
done <"$LIST"

exit "$status"
