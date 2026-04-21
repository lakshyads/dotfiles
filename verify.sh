#!/usr/bin/env bash
# verify.sh: End-to-end smoke test of the macOS developer setup.
#
# Runs non-destructive checks against every component installed by setup.sh.
# Exit code 0 if all pass; 1 if any fail (with summary).
#
# Usage:
#   ./verify.sh
#
# No args. No side effects beyond reading configs and running --version.

# shellcheck disable=SC2317  # Helper functions called indirectly via loops
# shellcheck disable=SC2088  # Tildes in display labels are intentional (for humans to read)

set -uo pipefail
# NOTE: deliberately NOT using `set -e` — we want to continue past failures
# to get a complete report, not halt at the first issue.

# ---- Counters ----
PASS=0
FAIL=0
WARN=0
FAILURES=()

# ---- Pretty output ----
pass()   { printf "\033[0;32m✓\033[0m %s\n" "$*"; PASS=$((PASS+1)); }
fail()   { printf "\033[0;31m✗\033[0m %s\n" "$*"; FAIL=$((FAIL+1)); FAILURES+=("$*"); }
warn_m() { printf "\033[0;33m!\033[0m %s\n" "$*"; WARN=$((WARN+1)); }
info()   { printf "\033[0;34m→\033[0m \033[1m%s\033[0m\n" "$*"; }

# ---- Helpers ----
check_command() {
  local cmd="$1"
  local label="${2:-$cmd}"
  if command -v "$cmd" >/dev/null 2>&1; then
    pass "$label available"
    return 0
  else
    fail "$label not found on PATH"
    return 1
  fi
}

check_version() {
  local cmd="$1"
  local label="${2:-$cmd}"
  if command -v "$cmd" >/dev/null 2>&1; then
    local ver
    ver=$("$cmd" --version 2>&1 | head -n1)
    pass "$label: $ver"
  else
    fail "$label not found"
  fi
}

check_file() {
  local path="$1"
  local label="${2:-$path}"
  if [[ -e "$path" ]]; then
    pass "$label exists"
  else
    fail "$label missing at $path"
  fi
}

check_symlink() {
  local path="$1"
  local label="${2:-$path}"
  if [[ -L "$path" ]]; then
    local target
    target=$(readlink "$path")
    pass "$label → $target"
  elif [[ -e "$path" ]]; then
    warn_m "$label exists but is not a symlink (expected symlink to dotfiles repo)"
  else
    fail "$label not found"
  fi
}

echo
info "=== macOS Developer Setup: End-to-End Verification ==="
echo

# ---- 1. Homebrew ----
info "1. Homebrew"
check_command brew "Homebrew"
if command -v brew >/dev/null 2>&1; then
  if [[ "$(brew --prefix)" == "/opt/homebrew" ]]; then
    pass "Homebrew prefix is /opt/homebrew (Apple Silicon)"
  else
    warn_m "Homebrew prefix is $(brew --prefix) (expected /opt/homebrew on Apple Silicon)"
  fi
fi
# Confirm login-shell PATH persistence
if grep -q "brew shellenv" "$HOME/.zprofile" 2>/dev/null; then
  pass "Homebrew PATH persisted in ~/.zprofile"
else
  fail "Homebrew PATH not in ~/.zprofile (login shells won't find brew)"
fi
echo

# ---- 2. Language runtimes (via asdf) ----
info "2. Language Runtimes (asdf)"
check_command asdf "asdf"
if command -v asdf >/dev/null 2>&1; then
  for lang in nodejs python golang; do
    if asdf current "$lang" >/dev/null 2>&1; then
      ver=$(asdf current "$lang" 2>/dev/null | awk 'NR==1 {print $2}')
      pass "asdf $lang: $ver"
    else
      fail "asdf $lang not configured"
    fi
  done
fi
# Also verify the actual binaries resolve through shims
check_command node "node"
check_command python "python"
check_command go "go"
# And match versions
if command -v node >/dev/null 2>&1; then
  pass "node version: $(node --version)"
fi
if command -v python >/dev/null 2>&1; then
  pass "python version: $(python --version)"
fi
if command -v go >/dev/null 2>&1; then
  pass "go version: $(go version | awk '{print $3}')"
fi
echo

# ---- 3. Shell stack ----
info "3. Shell (zsh, starship, antidote)"
if [[ "$SHELL" == *zsh* ]]; then
  pass "Login shell is zsh ($SHELL)"
else
  warn_m "Login shell is $SHELL (expected zsh); run: chsh -s $(which zsh)"
fi
check_command starship "Starship prompt"
check_file "/opt/homebrew/opt/antidote/share/antidote/antidote.zsh" "Antidote plugin manager"
echo

# ---- 4. Modern CLI tools ----
info "4. Modern CLI Tools"
for tool in rg fd bat eza zoxide fzf delta lazygit btop dust tldr atuin; do
  check_command "$tool" "$tool"
done
echo

# ---- 5. Git & GitHub CLI ----
info "5. Git & GitHub"
check_command git "git"
check_command gh "GitHub CLI"
if command -v git >/dev/null 2>&1; then
  name=$(git config --get user.name 2>/dev/null || echo "")
  email=$(git config --get user.email 2>/dev/null || echo "")
  if [[ -n "$name" ]]; then
    pass "git user.name: $name"
  else
    fail "git user.name not set (run: git config --global user.name \"Your Name\")"
  fi
  if [[ -n "$email" ]]; then
    pass "git user.email: $email"
  else
    fail "git user.email not set (run: git config --global user.email \"you@example.com\")"
  fi
fi
echo

# ---- 6. Claude Code ----
info "6. Claude Code"
check_command claude "Claude Code"
if ! command -v claude >/dev/null 2>&1 && [[ -x "$HOME/.local/bin/claude" ]]; then
  fail "Claude installed at ~/.local/bin/claude but not on PATH (add to ~/.zshrc)"
fi
echo

# ---- 7. Dotfile symlinks ----
info "7. Dotfile Symlinks"
check_symlink "$HOME/.zshrc" "~/.zshrc"
check_symlink "$HOME/.zsh_plugins.txt" "~/.zsh_plugins.txt"
check_symlink "$HOME/.tool-versions" "~/.tool-versions"
check_symlink "$HOME/.config/ghostty/config" "~/.config/ghostty/config"
check_symlink "$HOME/.config/starship.toml" "~/.config/starship.toml"
echo

# ---- 8. GUI Applications ----
info "8. GUI Applications"
APPS=(
  "Ghostty"
  "Visual Studio Code"
  "Cursor"
  "Docker"
  "Google Chrome"
  "1Password"
  "Rectangle"
  "AppCleaner"
  "Maccy"
)
for app in "${APPS[@]}"; do
  if [[ -d "/Applications/$app.app" ]]; then
    pass "$app installed"
  else
    fail "$app not found in /Applications"
  fi
done
echo

# ---- 9. Fonts ----
info "9. Nerd Fonts"
if fc-list 2>/dev/null | grep -qi "jetbrainsmono nerd font"; then
  pass "JetBrainsMono Nerd Font available"
elif compgen -G "$HOME/Library/Fonts/JetBrainsMono*" >/dev/null 2>&1; then
  pass "JetBrainsMono Nerd Font in ~/Library/Fonts"
elif compgen -G "/Library/Fonts/JetBrainsMono*" >/dev/null 2>&1; then
  pass "JetBrainsMono Nerd Font in /Library/Fonts"
else
  # Check Homebrew cask install path
  if brew list --cask 2>/dev/null | grep -q "font-jetbrains-mono-nerd-font"; then
    pass "JetBrainsMono Nerd Font installed via Homebrew cask"
  else
    warn_m "JetBrainsMono Nerd Font not detected (icons may render as boxes)"
  fi
fi
echo

# ---- 10. fzf key bindings ----
info "10. fzf Shell Integration"
check_file "$HOME/.fzf.zsh" "~/.fzf.zsh"
if grep -q "fzf.zsh" "$HOME/.zshrc" 2>/dev/null; then
  pass "fzf sourced from .zshrc"
else
  warn_m "fzf.zsh not sourced in .zshrc (Ctrl+R, Ctrl+T may not work)"
fi
echo

# ---- Summary ----
info "=== Summary ==="
printf "  \033[0;32m%d passed\033[0m, \033[0;33m%d warnings\033[0m, \033[0;31m%d failed\033[0m\n" "$PASS" "$WARN" "$FAIL"
echo

if [[ $FAIL -gt 0 ]]; then
  echo "Failures:"
  for f in "${FAILURES[@]}"; do
    printf "  \033[0;31m✗\033[0m %s\n" "$f"
  done
  echo
  exit 1
fi

printf "\033[0;32mAll critical checks passed.\033[0m\n"
exit 0
