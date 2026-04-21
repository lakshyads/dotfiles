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
done_ "Setup complete. Open Ghostty and run: exec zsh"
echo
info "Next steps:"
echo "  - (Optional) atuin register -u <username> -e <email>   # enable shell history sync"
echo "  - Sign into 1Password, Chrome, etc."
echo "  - Set Ghostty as your default terminal if desired"
