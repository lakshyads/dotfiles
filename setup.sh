#!/usr/bin/env bash
# setup.sh: Bootstrap a fresh macOS into a complete developer environment.
#
# Idempotent: safe to re-run. Each step checks its own preconditions.
#
# Usage:
#   cd ~/dotfiles
#   ./setup.sh

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info()  { printf "\033[0;34m→\033[0m %s\n" "$*"; }
warn()  { printf "\033[0;33m!\033[0m %s\n" "$*" >&2; }
done_() { printf "\033[0;32m✓\033[0m %s\n" "$*"; }

# ---- 1. Xcode Command Line Tools ----
if ! xcode-select -p >/dev/null 2>&1; then
  info "Installing Xcode Command Line Tools (GUI prompt)…"
  xcode-select --install
  warn "Re-run this script once CLT install finishes."
  exit 0
fi
done_ "Xcode Command Line Tools present"

# ---- 2. Homebrew ----
if ! command -v brew >/dev/null 2>&1; then
  info "Installing Homebrew…"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Ensure Homebrew is on PATH for login shells (idempotent: only adds if not already present)
if ! grep -q 'brew shellenv' "$HOME/.zprofile" 2>/dev/null; then
  info "Adding Homebrew to ~/.zprofile…"
  # shellcheck disable=SC2016
  # Intentional: single quotes so `eval` happens at login, not now.
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
fi
done_ "Homebrew installed"

# ---- 3. Brewfile ----
info "Installing Homebrew packages from Brewfile…"
brew bundle --file="$DOTFILES_DIR/Brewfile"
done_ "Brewfile installed"

# ---- 4. Symlink config files into place ----
info "Linking dotfiles into \$HOME…"
ln -sf "$DOTFILES_DIR/.zshrc"           "$HOME/.zshrc"
ln -sf "$DOTFILES_DIR/.zsh_plugins.txt" "$HOME/.zsh_plugins.txt"
ln -sf "$DOTFILES_DIR/.tool-versions"   "$HOME/.tool-versions"

mkdir -p "$HOME/.config/ghostty"
ln -sf "$DOTFILES_DIR/ghostty-config"   "$HOME/.config/ghostty/config"
ln -sf "$DOTFILES_DIR/starship.toml"    "$HOME/.config/starship.toml"

# LinearMouse: special handling because the app may have already created
# its own config file with settings you tweaked via the GUI. If a real file
# exists (not a symlink), back it up before replacing with our repo version.
mkdir -p "$HOME/.config/linearmouse"
LINEARMOUSE_TARGET="$HOME/.config/linearmouse/linearmouse.json"
if [[ -f "$LINEARMOUSE_TARGET" && ! -L "$LINEARMOUSE_TARGET" ]]; then
  BACKUP="$LINEARMOUSE_TARGET.backup.$(date +%Y%m%d-%H%M%S)"
  info "Existing LinearMouse config found; backing up to $(basename "$BACKUP")"
  mv "$LINEARMOUSE_TARGET" "$BACKUP"
fi
ln -sf "$DOTFILES_DIR/linearmouse.json" "$LINEARMOUSE_TARGET"

done_ "Dotfiles linked"

# ---- 5. fzf shell integration ----
info "Setting up fzf key bindings…"
"$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc
done_ "fzf ready"

# ---- 6. asdf plugins + language runtimes ----
info "Adding asdf plugins…"
asdf plugin add nodejs 2>/dev/null || true
asdf plugin add python 2>/dev/null || true
asdf plugin add golang 2>/dev/null || true

info "Installing language versions from .tool-versions (this can take a few minutes)…"
asdf install
done_ "Language runtimes installed"

# ---- 7. Claude Code (auto-updating native installer) ----
if ! command -v claude >/dev/null 2>&1; then
  info "Installing Claude Code…"
  curl -fsSL https://claude.ai/install.sh | bash
fi
done_ "Claude Code ready"

# ---- 8. Shell switch (Zsh is the macOS default since Catalina, but verify) ----
if [[ "$SHELL" != *"zsh"* ]]; then
  warn "Your login shell is $SHELL. Run: chsh -s $(which zsh)"
fi

echo
done_ "Setup complete."
echo
info "Next steps (in order):"
echo
echo "  1. Verify everything installed correctly:"
echo "       ./verify.sh"
echo
echo "  2. Reload your shell so new PATH and aliases take effect:"
echo "       exec zsh"
echo
echo "  3. Set your git identity (required before any commits):"
echo "       git config --global user.name  \"Your Name\""
echo "       git config --global user.email \"you@example.com\""
echo
echo "  4. Authenticate GitHub CLI (easiest path: uses SSH under the hood):"
echo "       gh auth login"
echo
echo "  5. Grant Accessibility permission to Maccy, Rectangle, and LinearMouse:"
echo "       System Settings > Privacy & Security > Accessibility"
echo "       (without this, their global hotkeys and mouse customization will not work)"
echo
echo "  6. Launch Docker Desktop once to complete its install:"
echo "       open -a Docker"
echo
echo "  7. Sign into GUI apps (1Password, Chrome, Cursor, VS Code)"
echo
echo "  8. Authenticate Claude Code:"
echo "       claude"
echo "       (follow the browser OAuth flow on first run)"
echo
echo "  9. (Optional) Enable Atuin shell history sync:"
echo "       atuin register -u <username> -e <email>"
echo "       atuin sync"
echo
echo "  10. (Optional) Authenticate cloud CLIs as needed:"
echo "        gcloud auth login"
echo
echo "  See README.md 'Manual Steps' section for full details."
