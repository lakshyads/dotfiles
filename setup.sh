#!/usr/bin/env bash
# setup.sh — Interactive bootstrap for a fresh macOS developer environment.
#
# Usage:
#   ./setup.sh           # interactive wizard
#   ./setup.sh --full    # non-interactive, install everything (CI / re-runs)
#
# Idempotent: safe to re-run at any time.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FULL=false
[[ "${1:-}" == "--full" ]] && FULL=true

# State flags set during selection; drive post-install steps.
DID_FZF=false
DID_ASDF=false
DID_CLAUDE=false
ASDF_LANGS=()

CAT_MODE=all   # current category mode: all | custom | skip

# ── Colors (disabled when not a TTY) ─────────────────────────────────────────
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

# ── Idempotent install wrappers ───────────────────────────────────────────────
formula() {
  if brew list --formula "$1" &>/dev/null 2>&1; then
    done_ "$1 (already installed)"
  else
    info "Installing $1 …"; brew install "$1"; done_ "$1"
  fi
}

cask_pkg() {
  if brew list --cask "$1" &>/dev/null 2>&1; then
    done_ "$1 (already installed)"
  else
    info "Installing $1 …"; brew install --cask "$1"; done_ "$1"
  fi
}

# ── Wizard helpers ────────────────────────────────────────────────────────────

# category <display-name> [<preview-line>]
#   Sets $CAT_MODE: all | custom | skip
#   In --full mode always sets all.
category() {
  local name="$1" preview="${2:-}"
  section "$name"
  [[ -n "$preview" ]] && printf "  ${preview}\n"
  if $FULL; then CAT_MODE=all; return; fi
  local ans
  printf "\n  Install?  ${W}[A]ll${R}  [c]ustomize  [s]kip  (default: A)  "
  read -r ans </dev/tty
  case "${ans:-a}" in
    [Cc]*) CAT_MODE=custom ;;
    [Ss]*) CAT_MODE=skip   ;;
    *)     CAT_MODE=all    ;;
  esac
}

# want <item-description>
#   Use only inside an `if` — returns 0=install, 1=skip.
#   all → always 0; skip → always 1; custom → prompts.
want() {
  [[ "$CAT_MODE" == skip   ]] && return 1
  [[ "$CAT_MODE" == all    ]] && return 0
  local ans
  printf "    %-50s [Y/n]  " "$1"
  read -r ans </dev/tty
  [[ "${ans:-y}" =~ ^[Yy] ]]
}

# ── Welcome ───────────────────────────────────────────────────────────────────
if ! $FULL; then
  printf "${W}${C}"
  printf '\n╔══════════════════════════════════════════════╗\n'
  printf   '║       macOS Developer Setup Wizard           ║\n'
  printf   '╚══════════════════════════════════════════════╝\n'
  printf "${R}\n"
  printf "  Idempotent — safe to re-run at any time.\n"
  printf "  Pass ${W}--full${R} to skip all prompts.\n\n"

  _ans=y
  printf "  Full install — recommended for a fresh Mac? [Y/n]  "
  read -r _ans </dev/tty
  if [[ "${_ans:-y}" =~ ^[Yy] ]]; then
    FULL=true
    info "Full install selected — no more prompts."
  else
    printf "\n  Custom install — you will be asked about each category.\n"
  fi
fi

# ── Prerequisites (always installed) ─────────────────────────────────────────
section "Prerequisites"
printf "  Xcode CLT and Homebrew are always installed — no prompt.\n"

if ! xcode-select -p >/dev/null 2>&1; then
  info "Installing Xcode Command Line Tools (GUI prompt) …"
  xcode-select --install
  warn "Re-run this script once CLT installation finishes."
  exit 0
fi
done_ "Xcode Command Line Tools"

if ! command -v brew >/dev/null 2>&1; then
  info "Installing Homebrew …"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
# shellcheck disable=SC2016
if ! grep -q 'brew shellenv' "$HOME/.zprofile" 2>/dev/null; then
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
fi
done_ "Homebrew"

# ── Version Control & Core Utilities ─────────────────────────────────────────
category "Version Control & Core Utilities" "git  gh  jq  tree  wget"

if want "git — version control";   then formula git;  fi
if want "gh — GitHub CLI";         then formula gh;   fi
if want "jq — JSON processor";     then formula jq;   fi
if want "tree — directory tree";   then formula tree; fi
if want "wget — HTTP downloader";  then formula wget; fi

# ── Modern CLI Tools ──────────────────────────────────────────────────────────
category "Modern CLI Tools" \
  "rg  fd  bat  eza  zoxide  fzf  delta  lazygit  btop  dust  tldr  atuin"

if want "ripgrep (rg) — fast grep, respects .gitignore"; then formula ripgrep;    fi
if want "fd — intuitive find replacement";               then formula fd;         fi
if want "bat — cat with syntax highlighting";            then formula bat;        fi
if want "eza — modern ls with icons and git status";     then formula eza;        fi
if want "zoxide (z) — smarter cd";                       then formula zoxide;     fi
if want "fzf — fuzzy finder (history, files, dirs)";     then formula fzf; DID_FZF=true; fi
if want "git-delta — syntax-highlighted git diffs";      then formula git-delta;  fi
if want "lazygit (lg) — full TUI for git";               then formula lazygit;    fi
if want "btop — modern resource monitor";                then formula btop;       fi
if want "dust — tree-based disk usage";                  then formula dust;       fi
if want "tldr — simplified man pages";                   then formula tldr;       fi
if want "atuin — SQLite-backed shell history";           then formula atuin;      fi

# ── Shell Productivity ────────────────────────────────────────────────────────
category "Shell Productivity" "starship  antidote"

if want "starship — cross-shell prompt (replaces Powerlevel10k)"; then formula starship;  fi
if want "antidote — Zsh plugin manager";                          then formula antidote; fi

# ── Language Runtimes ─────────────────────────────────────────────────────────
category "Language Runtimes (via asdf)" \
  "Node.js  Python  Go  Java  (versions from .tool-versions)"

if [[ "$CAT_MODE" != skip ]]; then
  DID_ASDF=true
  # Build deps are prerequisites for asdf plugins — always included with runtimes.
  info "Installing asdf and build prerequisites …"
  formula asdf
  formula coreutils
  formula openssl@3
  formula readline
  formula xz
  done_ "asdf + build prerequisites"

  if want "Node.js";  then ASDF_LANGS+=(nodejs);  fi
  if want "Python";   then ASDF_LANGS+=(python);   fi
  if want "Go";       then ASDF_LANGS+=(golang);   fi
  if want "Java";     then ASDF_LANGS+=(java);     fi
fi

# ── Containers ────────────────────────────────────────────────────────────────
category "Containers" "Docker Desktop — provides docker + docker compose"

if want "Docker Desktop"; then cask_pkg docker-desktop; fi

# ── Cloud Tooling ─────────────────────────────────────────────────────────────
category "Cloud Tooling" "Google Cloud CLI — gcloud, gsutil, bq"

if want "Google Cloud CLI (gcloud, gsutil, bq)"; then cask_pkg gcloud-cli; fi

# ── Editors & Terminal ────────────────────────────────────────────────────────
category "Editors & Terminal" "Ghostty  VS Code  Cursor  Claude Code"

if want "Ghostty — GPU-accelerated terminal";          then cask_pkg ghostty;            fi
if want "Visual Studio Code";                          then cask_pkg visual-studio-code; fi
if want "Cursor — AI-native code editor";              then cask_pkg cursor;             fi
if want "Claude Code — AI CLI (native installer)";     then DID_CLAUDE=true;             fi

# ── Browser ───────────────────────────────────────────────────────────────────
category "Browser" "Google Chrome"

if want "Google Chrome"; then cask_pkg google-chrome; fi

# ── Productivity Apps ─────────────────────────────────────────────────────────
category "Productivity Apps" \
  "Rectangle  1Password  AppCleaner  Maccy  LinearMouse  Postman"

if want "Rectangle — keyboard-driven window tiling";       then cask_pkg rectangle;   fi
if want "1Password — password manager";                    then cask_pkg 1password;   fi
if want "AppCleaner — clean app uninstalls";               then cask_pkg appcleaner;  fi
if want "Maccy — clipboard history (Cmd+Shift+C)";         then cask_pkg maccy;       fi
if want "LinearMouse — mouse customization";               then cask_pkg linearmouse; fi
if want "Postman — REST client & API testing";             then cask_pkg postman;     fi

# ── Developer Fonts ───────────────────────────────────────────────────────────
category "Developer Fonts" \
  "Nerd Fonts — required by Starship, eza icons, and TUI tools"

if want "JetBrains Mono Nerd Font (primary, default in Ghostty)"; then
  cask_pkg font-jetbrains-mono-nerd-font
fi
if want "Fira Code Nerd Font (alternative with ligatures)"; then
  cask_pkg font-fira-code-nerd-font
fi

# ── Dotfile symlinks (always) ─────────────────────────────────────────────────
section "Dotfile Symlinks"
info "Linking dotfiles into \$HOME …"

ln -sf "$DOTFILES_DIR/.zshrc"           "$HOME/.zshrc"
ln -sf "$DOTFILES_DIR/.zsh_plugins.txt" "$HOME/.zsh_plugins.txt"
ln -sf "$DOTFILES_DIR/.tool-versions"   "$HOME/.tool-versions"

mkdir -p "$HOME/.config/ghostty"
ln -sf "$DOTFILES_DIR/ghostty-config"   "$HOME/.config/ghostty/config"
ln -sf "$DOTFILES_DIR/starship.toml"    "$HOME/.config/starship.toml"

# LinearMouse: back up any pre-existing real file before replacing with symlink.
mkdir -p "$HOME/.config/linearmouse"
LINEARMOUSE_TARGET="$HOME/.config/linearmouse/linearmouse.json"
if [[ -f "$LINEARMOUSE_TARGET" && ! -L "$LINEARMOUSE_TARGET" ]]; then
  BACKUP="$LINEARMOUSE_TARGET.backup.$(date +%Y%m%d-%H%M%S)"
  info "Existing LinearMouse config found; backing up to $(basename "$BACKUP")"
  mv "$LINEARMOUSE_TARGET" "$BACKUP"
fi
ln -sf "$DOTFILES_DIR/linearmouse.json" "$LINEARMOUSE_TARGET"
done_ "Dotfiles linked"

# ── Git Configuration ─────────────────────────────────────────────────────────
section "Git Configuration"

# Default branch is always set — not personal, main is the universal default.
_branch=main
if ! $FULL; then
  _cur_branch=$(git config --global init.defaultBranch 2>/dev/null || echo "main")
  printf "  Default branch [%s]: " "$_cur_branch"
  read -r _branch </dev/tty
  _branch="${_branch:-$_cur_branch}"
fi
git config --global init.defaultBranch "$_branch"
done_ "git init.defaultBranch = $_branch"

# Name and email are personal — prompt in interactive mode, report state in --full.
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
  # --full mode: can't prompt, just report current state.
  [[ -n "$_cur_name" ]]  && done_ "git user.name  = $_cur_name"  || warn "git user.name not set — run: git config --global user.name \"Your Name\""
  [[ -n "$_cur_email" ]] && done_ "git user.email = $_cur_email" || warn "git user.email not set — run: git config --global user.email \"you@example.com\""
fi

# ── fzf shell integration ─────────────────────────────────────────────────────
if $DID_FZF; then
  section "fzf Shell Integration"
  info "Wiring Ctrl+T, Ctrl+R, Alt+C key bindings …"
  "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc
  done_ "fzf shell integration ready"
fi

# ── asdf plugins + language runtimes ─────────────────────────────────────────
if $DID_ASDF && [[ ${#ASDF_LANGS[@]} -gt 0 ]]; then
  section "Language Runtimes"
  info "Adding asdf plugins …"
  for lang in "${ASDF_LANGS[@]}"; do
    asdf plugin add "$lang" 2>/dev/null || true
    done_ "asdf plugin: $lang"
  done
  info "Installing versions from .tool-versions (may take a few minutes) …"
  asdf install
  done_ "Language runtimes installed"
fi

# ── Claude Code ───────────────────────────────────────────────────────────────
if $DID_CLAUDE; then
  section "Claude Code"
  if ! command -v claude >/dev/null 2>&1; then
    info "Installing Claude Code via native installer …"
    curl -fsSL https://claude.ai/install.sh | bash
  fi
  done_ "Claude Code ready"
fi

# ── Shell check ───────────────────────────────────────────────────────────────
if [[ "$SHELL" != *"zsh"* ]]; then
  warn "Your login shell is $SHELL. Run: chsh -s $(which zsh)"
fi

# ── Done ──────────────────────────────────────────────────────────────────────
printf "\n${W}${G}"
printf "╔══════════════════════════════════════════════╗\n"
printf "║            Setup complete!  ✓                ║\n"
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
echo "  6. Sign into GUI apps (1Password, Chrome, Cursor, VS Code)"
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
echo "  See README.md 'Manual Steps' section for full details."
