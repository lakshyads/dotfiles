#!/usr/bin/env bash
# rebuild.sh — Daily-use: re-apply the nix-darwin config after editing it.
#
# Usage:
#   ./rebuild.sh              # build + apply
#   ./rebuild.sh --dry-run    # build only, don't apply (validate before switching)

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOST_LABEL="mac" #mac

if [[ "${1:-}" == "--dry-run" ]]; then
  nix build "$DOTFILES_DIR#darwinConfigurations.${HOST_LABEL}.system" --dry-run
else
  # sudo resets PATH and won't find darwin-rebuild on it, so use the full
  # path — same reason bootstrap.sh's first switch needs it.
  sudo /run/current-system/sw/bin/darwin-rebuild switch --flake "$DOTFILES_DIR#${HOST_LABEL}"
  # Installs anything newly added to home/npm-globals.txt; never upgrades unpinned ones.
  "$DOTFILES_DIR/npm-globals.sh" sync || echo "npm globals sync had failures — re-run: ./npm-globals.sh" >&2
  # Installs anything newly added to home/agent-skills.txt; never updates existing ones.
  "$DOTFILES_DIR/agent-skills.sh" sync || echo "agent skills sync had failures; re-run: ./agent-skills.sh" >&2
fi
