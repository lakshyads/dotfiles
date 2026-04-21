# ~/.zshrc
# macOS developer environment. Wires together Homebrew, asdf, starship, antidote, and modern CLI tools.
#
# Load order matters here. Each section below explains why.

# ---- 1. Homebrew PATH (Apple Silicon) ----
# Must come first; most other tools live under /opt/homebrew.
eval "$(/opt/homebrew/bin/brew shellenv)"

# ---- 2. asdf shims ----
# Must come before any tool that might invoke node/python/go. Uses the Go-rewrite
# style (asdf 0.16+); the old `source asdf.sh` approach is deprecated.
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# ---- 2b. Claude Code (native installer puts binary here) ----
export PATH="$HOME/.local/bin:$PATH"

# ---- 3. Atuin (SQLite shell history) ----
# MUST load before antidote, so that zsh-syntax-highlighting (loaded LAST by
# antidote) can hook atuin's rebound Ctrl+R widget. Reversing this order causes
# autosuggestions/syntax-highlighting to silently fail.
# Replaces Ctrl+R with a full-screen history search UI.
eval "$(atuin init zsh)"

# ---- 4. Antidote plugin manager ----
# Loads the static plugin bundle. Plugin list lives in ~/.zsh_plugins.txt.
# Plugin order inside that file matters: zsh-syntax-highlighting MUST be last.
source /opt/homebrew/opt/antidote/share/antidote/antidote.zsh
antidote load

# ---- 5. Starship prompt ----
# Must come after plugins so it renders on top of their setup. Config lives
# in ~/.config/starship.toml.
eval "$(starship init zsh)"

# ---- 6. zoxide (smarter cd) ----
# `z <partial>` jumps to any directory you've visited. Kept as a separate command
# from `cd` on purpose: aliasing `cd` to `z` breaks scripts that expect POSIX cd behavior.
eval "$(zoxide init zsh)"

# ---- 7. fzf (fuzzy finder) ----
# Binds Ctrl+R (history), Ctrl+T (file picker), Alt+C (directory picker).
# Note: atuin (loaded earlier) also binds Ctrl+R. Whichever loads LAST wins;
# here fzf wins at binding, but atuin's UI is invoked by fzf's Ctrl+R hook.
# Requires `$(brew --prefix)/opt/fzf/install` to have been run once.
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# fzf preview integration. Uses bat for file contents, eza for directory trees.
export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# ---- 8. Modern CLI aliases ----
# Drop-in replacements. The classics remain available under their original names.
alias ls='eza --icons --group-directories-first'
alias ll='eza -lah --git --icons'
alias lt='eza --tree --level=2 --icons'
alias cat='bat --paging=never'
alias top='btop'
alias du='dust'

# Deliberately NOT aliased:
#   - grep  -> rg   (rg has different flag semantics; breaks scripts/pipes)
#   - find  -> fd   (same reason)
#   - cd    -> z    (zoxide; breaks scripts assuming POSIX cd)
# Use `rg`, `fd`, and `z` as their own commands instead.

# ---- 9. Navigation shortcuts ----
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# ---- 10. Git shortcuts ----
alias g='git'
alias gs='git status'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate -20'
alias lg='lazygit'

# ---- 11. Reload helper ----
alias reload='exec zsh'
