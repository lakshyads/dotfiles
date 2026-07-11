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
fi
