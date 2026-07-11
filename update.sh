#!/usr/bin/env bash
# update.sh — Update everything this repo manages.
#
# Usage:
#   ./update.sh
#
# Runs each updater in sequence; a failure in one section does not abort others.

set -uo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

# ── Nix flake inputs ──────────────────────────────────────────────────────────
# Bumps the pins in flake.lock (nixpkgs, nix-darwin, home-manager,
# nix-homebrew) to their latest revisions on the tracked branches. This does
# NOT apply anything by itself — run ./rebuild.sh afterward.
section "Nix flake inputs"
if command -v nix >/dev/null 2>&1; then
  run "Update flake.lock" nix flake update --flake "$DOTFILES_DIR"
  warn "flake.lock updated — run ./rebuild.sh to apply, then commit the lock file change."
else
  warn "nix not found — skipping (run ./bootstrap.sh first)"
fi

# ── Homebrew ──────────────────────────────────────────────────────────────────
# What's INSTALLED is declared by configuration.nix's `homebrew` block — this
# doesn't change that. It just upgrades those already-declared packages to
# their latest available version right now, same as `onActivation.autoUpdate
# = true` already does on every ./rebuild.sh — this is just a faster path
# when you want it done immediately without a full switch.
section "Homebrew"
run "Update formulae metadata"  brew update
run "Upgrade formulae"          brew upgrade
run "Upgrade casks"             brew upgrade --cask
run "Cleanup old versions"      brew cleanup

# ── asdf plugins ─────────────────────────────────────────────────────────────
# Runtimes stay outside Nix's view by design (per-project .tool-versions
# overrides don't fit Nix's model) — this genuinely still needs a manual step.
section "asdf plugins"
if command -v asdf >/dev/null 2>&1; then
  run "Update all asdf plugins" asdf plugin update --all
else
  warn "asdf not found — skipping"
fi

# ── Summary ───────────────────────────────────────────────────────────────────
printf "\n${G}${W}Done.${R}\n"
printf "If flake.lock changed above, run ${W}./rebuild.sh${R} to apply it.\n"
