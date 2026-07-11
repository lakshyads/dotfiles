#!/usr/bin/env bash
# bootstrap.sh — Single entry point for a fresh Mac.
#
# Usage:
#   ./bootstrap.sh           # interactive (prompts for git identity)
#   ./bootstrap.sh --full    # non-interactive (reports git identity, doesn't prompt)
#
# What it does, in order:
#   1. Installs Xcode Command Line Tools, if missing.
#   2. Installs Determinate Nix, if it isn't already installed.
#   3. Symlinks this repo to ~/.dotfiles (home.nix points at config files
#      through that path).
#   4. Checks the `user` variable in flake.nix against your actual macOS
#      username, and offers to fix it for you if they differ.
#   5. Runs the first `darwin-rebuild switch` — this installs every package
#      (Homebrew via nix-homebrew, CLI tools via home.nix) and wires up all
#      dotfile symlinks. Everything past this point is stuff Nix genuinely
#      can't express:
#   6. Registers asdf plugins and installs runtimes from .tool-versions
#      (per-project .tool-versions overrides don't fit Nix's model, so
#      runtimes stay asdf-managed by design).
#   7. Prompts for git identity (still written directly to ~/.gitconfig —
#      pager/merge/delta config is now nix-managed separately via
#      ~/.config/git/config).
#
# After this, `darwin-rebuild` exists on PATH and you're on the normal
# workflow: edit files, then run ./rebuild.sh.
#
# Idempotent: safe to re-run at any time (steps that are already done are skipped).

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOST_LABEL="mac"
FULL=false
[[ "${1:-}" == "--full" ]] && FULL=true

if [[ -t 1 ]]; then
  G=$'\033[0;32m' Y=$'\033[0;33m' B=$'\033[0;34m' C=$'\033[0;36m' W=$'\033[1m' R=$'\033[0m'
else
  G='' Y='' B='' C='' W='' R=''
fi
info()    { printf "${B}  →  ${R}%s\n" "$*"; }
done_()   { printf "${G}  ✓  ${R}%s\n" "$*"; }
warn()    { printf "${Y}  !  ${R}%s\n" "$*" >&2; }
section() { printf "\n${W}${C}━━  %s${R}\n" "$*"; }

# ── 1. Xcode Command Line Tools ──────────────────────────────────────────────
section "Xcode Command Line Tools"
if ! xcode-select -p >/dev/null 2>&1; then
  info "Installing Xcode Command Line Tools (GUI prompt) …"
  xcode-select --install
  warn "Re-run this script once CLT installation finishes."
  exit 0
fi
done_ "Xcode Command Line Tools"

# ── 2. Determinate Nix ───────────────────────────────────────────────────────
section "Nix"
if ! command -v nix &>/dev/null; then
  info "Installing Determinate Nix..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm
  done_ "Determinate Nix installed"
  warn "Open a new terminal (or re-run this script) so the Nix environment is loaded."
  exit 0
else
  done_ "Nix already installed"
fi

# ── 3. Symlink repo to ~/.dotfiles ──────────────────────────────────────────
if [[ ! -e "$HOME/.dotfiles" ]]; then
  ln -s "$DOTFILES_DIR" "$HOME/.dotfiles"
  done_ "Symlinked $DOTFILES_DIR -> ~/.dotfiles"
elif [[ "$(readlink "$HOME/.dotfiles" 2>/dev/null)" != "$DOTFILES_DIR" ]]; then
  warn "~/.dotfiles exists and points somewhere else — leaving it alone."
else
  done_ "~/.dotfiles already linked"
fi

# ── 4. Username check ────────────────────────────────────────────────────────
ACTUAL_USER="$(whoami)"
DECLARED_USER="$(grep -o 'user = "[^"]*"' "$DOTFILES_DIR/flake.nix" | head -1 | sed 's/user = "\(.*\)"/\1/')"
if [[ "$ACTUAL_USER" != "$DECLARED_USER" ]]; then
  warn "flake.nix declares user \"$DECLARED_USER\" but this Mac's user is \"$ACTUAL_USER\"."
  read -rp "  Update flake.nix to use \"$ACTUAL_USER\"? [y/N] " REPLY
  if [[ "$REPLY" =~ ^[Yy]$ ]]; then
    sed -i '' "s/user = \"$DECLARED_USER\"/user = \"$ACTUAL_USER\"/" "$DOTFILES_DIR/flake.nix"
    done_ "Updated flake.nix"
  else
    warn "Leaving flake.nix as-is — the switch below may fail."
  fi
else
  done_ "flake.nix user matches this Mac ($ACTUAL_USER)"
fi

# ── 5. First switch ──────────────────────────────────────────────────────────
section "darwin-rebuild switch"
info "Running first darwin-rebuild switch (this will prompt for your password)..."
sudo nix run nix-darwin/nix-darwin-26.05#darwin-rebuild -- switch --flake "$DOTFILES_DIR#${HOST_LABEL}"
done_ "nix-darwin bootstrapped — packages installed, dotfiles symlinked."

# ── 6. Language Runtimes (asdf) ───────────────────────────────────────────────
# asdf itself just got installed via configuration.nix's homebrew.brews.
# Plugins and the actual runtime installs from .tool-versions aren't Nix's job.
section "Language Runtimes (asdf)"
if command -v asdf >/dev/null 2>&1; then
  while read -r lang _version; do
    [[ -z "$lang" ]] && continue
    asdf plugin add "$lang" 2>/dev/null || true
    done_ "asdf plugin: $lang"
  done < "$DOTFILES_DIR/.tool-versions"
  info "Installing versions from .tool-versions (may take a few minutes) …"
  asdf install
  done_ "Language runtimes installed"
else
  warn "asdf not found on PATH yet — open a new terminal and re-run this script."
fi

# ── 7. Git Configuration ─────────────────────────────────────────────────────
# Identity stays here (not home-manager's programs.git) so it's easily
# settable per-machine and writes directly to mutable ~/.gitconfig.
# Pager/merge/delta config is nix-managed separately via home.nix's
# programs.git.settings, applied to ~/.config/git/config.
section "Git Configuration"

_branch=main
if ! $FULL; then
  _cur_branch=$(git config --global init.defaultBranch 2>/dev/null || echo "main")
  printf "  Default branch [%s]: " "$_cur_branch"
  read -r _branch </dev/tty
  _branch="${_branch:-$_cur_branch}"
fi
git config --global init.defaultBranch "$_branch"
done_ "git init.defaultBranch = $_branch"

_cur_name=$(git config --global user.name 2>/dev/null || echo "")
_cur_email=$(git config --global user.email 2>/dev/null || echo "")

if ! $FULL; then
  printf "  Name"
  [[ -n "$_cur_name" ]] && printf " [%s]" "$_cur_name"
  printf ": "
  read -r _name </dev/tty
  _name="${_name:-$_cur_name}"

  printf "  Email"
  [[ -n "$_cur_email" ]] && printf " [%s]" "$_cur_email"
  printf ": "
  read -r _email </dev/tty
  _email="${_email:-$_cur_email}"

  if [[ -n "$_name" ]];  then git config --global user.name  "$_name";  done_ "git user.name  = $_name";  else warn "git user.name not set — run: git config --global user.name \"Your Name\"";  fi
  if [[ -n "$_email" ]]; then git config --global user.email "$_email"; done_ "git user.email = $_email"; else warn "git user.email not set — run: git config --global user.email \"you@example.com\""; fi
else
  [[ -n "$_cur_name" ]]  && done_ "git user.name  = $_cur_name"  || warn "git user.name not set — run: git config --global user.name \"Your Name\""
  [[ -n "$_cur_email" ]] && done_ "git user.email = $_cur_email" || warn "git user.email not set — run: git config --global user.email \"you@example.com\""
fi

if [[ "$SHELL" != *"zsh"* ]]; then
  warn "Your login shell is $SHELL. Run: chsh -s $(which zsh)"
fi

# ── Done ──────────────────────────────────────────────────────────────────────
printf "\n${W}${G}"
printf "╔══════════════════════════════════════════════╗\n"
printf "║            Bootstrap complete!  ✓            ║\n"
printf "╚══════════════════════════════════════════════╝\n"
printf "${R}\n"

info "Next steps (in order):"
echo
echo "  1. Verify everything installed correctly:"
echo "       ./verify.sh"
echo
echo "  2. Reload your shell so new PATH and aliases take effect:"
echo "       exec zsh"
echo
echo "  3. Authenticate GitHub CLI:"
echo "       gh auth login"
echo
echo "  4. Grant Accessibility permission to Maccy, Rectangle, and LinearMouse:"
echo "       System Settings > Privacy & Security > Accessibility"
echo
echo "  5. Launch Docker Desktop once to complete its install:"
echo "       open -a Docker"
echo
echo "  6. Sign into GUI apps (Chrome, Cursor, VS Code)"
echo
echo "  7. Authenticate Claude Code:"
echo "       claude"
echo
echo "  8. (Optional) Enable Atuin shell history sync:"
echo "       atuin register -u <username> -e <email>"
echo
echo "  9. (Optional) Authenticate cloud CLIs:"
echo "        gcloud auth login"
echo
echo "  From now on, after editing config: ./rebuild.sh"
echo "  See README.md 'Manual Steps' section for full details."
