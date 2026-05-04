#!/usr/bin/env bash
# verify.sh: End-to-end smoke test of the macOS developer setup.
#
# Runs non-destructive checks against every component installed by setup.sh:
# binaries, symlinks (existence + target), config file content, GUI apps, fonts.
#
# Exit code 0 if all critical checks pass; 1 if any fail (with summary).
#
# Usage:
#   ./verify.sh

# shellcheck disable=SC2317  # helpers called indirectly via loops
# shellcheck disable=SC2088  # tildes in display labels are intentional

set -uo pipefail
# Deliberately NOT set -e — continue past individual failures for a full report.

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PASS=0; FAIL=0; WARN=0
FAILURES=()

# ── Output helpers ────────────────────────────────────────────────────────────
pass()   { printf "\033[0;32m  ✓\033[0m  %s\n"  "$*"; PASS=$((PASS+1)); }
fail()   { printf "\033[0;31m  ✗\033[0m  %s\n"  "$*"; FAIL=$((FAIL+1)); FAILURES+=("$*"); }
warn_m() { printf "\033[0;33m  !\033[0m  %s\n"  "$*"; WARN=$((WARN+1)); }
info()   { printf "\n\033[1;36m━━  %s\033[0m\n" "$*"; }

# ── Check helpers ─────────────────────────────────────────────────────────────

check_command() {
  local cmd="$1" label="${2:-$1}"
  if command -v "$cmd" >/dev/null 2>&1; then
    pass "$label on PATH"
  else
    fail "$label not found on PATH"
  fi
}

# Verify a symlink exists AND points into the dotfiles repo.
check_symlink() {
  local path="$1" label="${2:-$path}"
  if [[ -L "$path" ]]; then
    local target; target=$(readlink "$path")
    if [[ "$target" == "$DOTFILES_DIR"* ]]; then
      pass "$label → $target"
    else
      warn_m "$label is a symlink but points outside dotfiles repo: $target"
    fi
  elif [[ -e "$path" ]]; then
    warn_m "$label exists but is not a symlink (expected symlink into dotfiles repo)"
  else
    fail "$label missing"
  fi
}

# Verify a config file contains an expected pattern.
check_contains() {
  local file="$1" pattern="$2" label="$3"
  if [[ ! -f "$file" ]]; then
    fail "$label: file not found ($file)"
  elif grep -q "$pattern" "$file" 2>/dev/null; then
    pass "$label"
  else
    fail "$label  (expected pattern not found: $pattern)"
  fi
}

# Verify a file is valid JSON.
check_json() {
  local file="$1" label="${2:-$file}"
  if [[ ! -f "$file" ]]; then
    fail "$label: file not found"
  elif python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$file" 2>/dev/null; then
    pass "$label is valid JSON"
  else
    fail "$label is not valid JSON"
  fi
}

echo
printf "\033[1;36m══  macOS Developer Setup: Verification  ══\033[0m\n"

# ── 1. Homebrew ───────────────────────────────────────────────────────────────
info "1. Homebrew"
check_command brew "Homebrew"
if command -v brew >/dev/null 2>&1; then
  prefix="$(brew --prefix)"
  if [[ "$prefix" == "/opt/homebrew" ]]; then
    pass "Homebrew prefix: /opt/homebrew (Apple Silicon)"
  else
    warn_m "Homebrew prefix: $prefix (expected /opt/homebrew on Apple Silicon)"
  fi
fi
if grep -q "brew shellenv" "$HOME/.zprofile" 2>/dev/null; then
  pass "Homebrew PATH persisted in ~/.zprofile"
else
  fail "Homebrew PATH missing from ~/.zprofile (login shells won't find brew)"
fi
# Verify Brewfile is fully satisfied.
if command -v brew >/dev/null 2>&1; then
  if brew bundle check --file="$DOTFILES_DIR/Brewfile" --quiet 2>/dev/null; then
    pass "All Brewfile packages installed"
  else
    warn_m "Some Brewfile packages not installed — run: brew bundle"
  fi
fi

# ── 2. Language Runtimes (asdf) ───────────────────────────────────────────────
info "2. Language Runtimes (asdf)"
check_command asdf "asdf"
if command -v asdf >/dev/null 2>&1; then
  for lang in nodejs python golang java; do
    if asdf current "$lang" >/dev/null 2>&1; then
      ver=$(asdf current "$lang" 2>/dev/null | awk -v l="$lang" '$1 == l {print $2}')
      tv_ver=$(grep "^${lang}" "$DOTFILES_DIR/.tool-versions" 2>/dev/null | awk '{print $2}')
      if [[ -n "$tv_ver" && "$ver" == "$tv_ver" ]]; then
        pass "asdf $lang: $ver (matches .tool-versions)"
      elif [[ -n "$tv_ver" ]]; then
        warn_m "asdf $lang: active=$ver, .tool-versions=$tv_ver (mismatch)"
      else
        pass "asdf $lang: $ver"
      fi
    else
      fail "asdf $lang not configured (run: asdf plugin add $lang && asdf install)"
    fi
  done
  # Verify shim binaries resolve.
  for bin in node python go java; do
    check_command "$bin" "$bin shim"
  done
fi

# ── 3. Shell Stack ────────────────────────────────────────────────────────────
info "3. Shell Stack"
if [[ "$SHELL" == *zsh* ]]; then
  pass "Login shell: zsh ($SHELL)"
else
  warn_m "Login shell is $SHELL (expected zsh) — run: chsh -s $(which zsh 2>/dev/null || echo zsh)"
fi
check_command starship "Starship"
if [[ -f "/opt/homebrew/opt/antidote/share/antidote/antidote.zsh" ]]; then
  pass "Antidote plugin manager installed"
else
  fail "Antidote not found at expected path"
fi

# .zshrc initializations
check_contains "$HOME/.zshrc" "antidote"              ".zshrc sources antidote"
check_contains "$HOME/.zshrc" "starship init"         ".zshrc initializes Starship"
check_contains "$HOME/.zshrc" "asdf"                  ".zshrc initializes asdf"
check_contains "$HOME/.zshrc" "zoxide init"           ".zshrc initializes zoxide"
check_contains "$HOME/.zshrc" "atuin init"            ".zshrc initializes atuin"

# .zsh_plugins.txt — all three plugins must be present
check_contains "$HOME/.zsh_plugins.txt" "zsh-autosuggestions"  ".zsh_plugins.txt: zsh-autosuggestions"
check_contains "$HOME/.zsh_plugins.txt" "zsh-completions"      ".zsh_plugins.txt: zsh-completions"
check_contains "$HOME/.zsh_plugins.txt" "zsh-syntax-highlighting" ".zsh_plugins.txt: zsh-syntax-highlighting"

# ── 4. Modern CLI Tools ───────────────────────────────────────────────────────
info "4. Modern CLI Tools"
for tool in rg fd bat eza zoxide fzf delta lazygit btop dust tldr atuin; do
  check_command "$tool" "$tool"
done

# ── 5. Git & GitHub CLI ───────────────────────────────────────────────────────
info "5. Git & GitHub"
check_command git  "git"
check_command gh   "GitHub CLI"
if command -v git >/dev/null 2>&1; then
  name=$(git config --get user.name  2>/dev/null || echo "")
  email=$(git config --get user.email 2>/dev/null || echo "")
  branch=$(git config --get init.defaultBranch 2>/dev/null || echo "")
  [[ -n "$name"   ]] && pass "git user.name: $name"   || fail "git user.name not set"
  [[ -n "$email"  ]] && pass "git user.email: $email"  || fail "git user.email not set"
  [[ -n "$branch" ]] && pass "git init.defaultBranch: $branch" \
                     || warn_m "git init.defaultBranch not set (will default to 'master')"
fi

# ── 6. Cloud Tools ────────────────────────────────────────────────────────────
info "6. Cloud Tools"
check_command gcloud "gcloud (Google Cloud CLI)"
check_command gh     "gh (GitHub CLI)"

# ── 7. Claude Code ────────────────────────────────────────────────────────────
info "7. Claude Code"
if command -v claude >/dev/null 2>&1; then
  pass "claude on PATH"
elif [[ -x "$HOME/.local/bin/claude" ]]; then
  fail "claude at ~/.local/bin/claude but not on PATH (add ~/.local/bin to PATH in ~/.zshrc)"
else
  fail "Claude Code not found (run: curl -fsSL https://claude.ai/install.sh | bash)"
fi

# ── 8. Dotfile Symlinks ───────────────────────────────────────────────────────
info "8. Dotfile Symlinks"
check_symlink "$HOME/.zshrc"                                "~/.zshrc"
check_symlink "$HOME/.zsh_plugins.txt"                      "~/.zsh_plugins.txt"
check_symlink "$HOME/.tool-versions"                        "~/.tool-versions"
check_symlink "$HOME/.config/ghostty/config"                "~/.config/ghostty/config"
check_symlink "$HOME/.config/starship.toml"                 "~/.config/starship.toml"
check_symlink "$HOME/.config/linearmouse/linearmouse.json"  "~/.config/linearmouse/linearmouse.json"

# ── 9. Config File Integrity ──────────────────────────────────────────────────
info "9. Config File Integrity"

# Ghostty
GHOSTTY_CFG="$HOME/.config/ghostty/config"
check_contains "$GHOSTTY_CFG" "font-family"         "ghostty-config: font-family set"
check_contains "$GHOSTTY_CFG" "term = xterm-256color" "ghostty-config: term=xterm-256color (SSH safety)"
check_contains "$GHOSTTY_CFG" "theme"               "ghostty-config: theme set"

# Starship
if [[ -f "$HOME/.config/starship.toml" ]]; then
  if [[ -s "$HOME/.config/starship.toml" ]]; then
    pass "starship.toml exists and is non-empty"
  else
    warn_m "starship.toml is empty"
  fi
else
  fail "starship.toml not found"
fi

# LinearMouse — must be valid JSON
check_json "$HOME/.config/linearmouse/linearmouse.json" "linearmouse.json"

# ── 10. GUI Applications ──────────────────────────────────────────────────────
info "10. GUI Applications"
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
  "LinearMouse"
  "Granola"
  "Postman"
)
for app in "${APPS[@]}"; do
  if [[ -d "/Applications/$app.app" ]]; then
    pass "$app"
  else
    fail "$app not found in /Applications"
  fi
done

# ── 11. Fonts ─────────────────────────────────────────────────────────────────
info "11. Nerd Fonts"
for font_pattern in "JetBrainsMono" "FiraCode"; do
  label="${font_pattern} Nerd Font"
  if brew list --cask 2>/dev/null | grep -qi "$(echo "$font_pattern" | tr '[:upper:]' '[:lower:]')"; then
    pass "$label (Homebrew cask)"
  elif compgen -G "$HOME/Library/Fonts/${font_pattern}*" >/dev/null 2>&1 \
    || compgen -G "/Library/Fonts/${font_pattern}*" >/dev/null 2>&1; then
    pass "$label (font directory)"
  else
    warn_m "$label not detected (icons may render as boxes)"
  fi
done

# ── 12. fzf Shell Integration ─────────────────────────────────────────────────
info "12. fzf Shell Integration"
if [[ -f "$HOME/.fzf.zsh" ]]; then
  pass "~/.fzf.zsh exists (key bindings installed)"
else
  fail "~/.fzf.zsh missing — run: \$(brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc"
fi
check_contains "$HOME/.zshrc" "fzf.zsh" ".zshrc sources fzf key bindings"

# ── Summary ───────────────────────────────────────────────────────────────────
printf "\n\033[1;36m━━  Summary\033[0m\n"
printf "  \033[0;32m%d passed\033[0m   \033[0;33m%d warnings\033[0m   \033[0;31m%d failed\033[0m\n\n" \
  "$PASS" "$WARN" "$FAIL"

if [[ $FAIL -gt 0 ]]; then
  printf "\033[0;31mFailed checks:\033[0m\n"
  for f in "${FAILURES[@]}"; do
    printf "  \033[0;31m✗\033[0m  %s\n" "$f"
  done
  echo
  exit 1
fi

printf "\033[0;32mAll critical checks passed.\033[0m\n"
exit 0
