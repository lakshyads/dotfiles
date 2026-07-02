#!/usr/bin/env bash
# update.sh — Update all package managers and tools.
#
# Usage:
#   ./update.sh
#
# Runs each updater in sequence; a failure in one section does not abort others.

set -uo pipefail

# ── Colors ────────────────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
  G=$'\033[0;32m' Y=$'\033[0;33m' B=$'\033[0;34m'
  C=$'\033[0;36m' W=$'\033[1m' R=$'\033[0m'
else
  G='' Y='' B='' C='' W='' R=''
fi

info()    { printf "${B}  →  ${R}%s\n" "$*"; }
done_()   { printf "${G}  ✓  ${R}%s\n" "$*"; }
warn()    { printf "${Y}  !  ${R}%s\n" "$*" >&2; }
section() { printf "\n${W}${C}━━  %s${R}\n" "$*"; }

run() {
  # run <label> <cmd> [args…]
  local label="$1"; shift
  info "$label …"
  if "$@"; then
    done_ "$label"
  else
    warn "$label failed (exit $?)"
  fi
}

# ── Homebrew ──────────────────────────────────────────────────────────────────
section "Homebrew"
run "Update formulae metadata"  brew update
run "Upgrade formulae"          brew upgrade
run "Upgrade casks"             brew upgrade --cask
run "Cleanup old versions"      brew cleanup

# ── Zsh plugins (antidote) ────────────────────────────────────────────────────
section "Zsh plugins (antidote)"
if command -v antidote >/dev/null 2>&1; then
  run "Update plugins" antidote update
else
  warn "antidote not found — skipping"
fi

# ── asdf plugins ─────────────────────────────────────────────────────────────
section "asdf plugins"
if command -v asdf >/dev/null 2>&1; then
  run "Update all asdf plugins" asdf plugin update --all
else
  warn "asdf not found — skipping"
fi

# ── Claude Code CLI ───────────────────────────────────────────────────────────
section "Claude Code"
if command -v claude >/dev/null 2>&1; then
  run "Update Claude Code" claude update
else
  warn "claude not found — skipping"
fi

# ── Summary ───────────────────────────────────────────────────────────────────
printf "\n${G}${W}Done.${R}\n"
