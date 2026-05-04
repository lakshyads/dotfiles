# Brewfile: macOS Developer Setup
#
# Usage:
#   brew bundle                    # install everything
#   brew bundle check              # dry-run check
#   brew bundle cleanup            # remove anything not listed here
#   brew bundle list --all         # show what would be installed
#
# Language runtimes are NOT in this file by design; they're managed by asdf
# via a committed .tool-versions file. See .tool-versions alongside this
# Brewfile. Claude Code is also excluded by design: it uses its own
# auto-updating native installer.

# ---- Version control & core utilities ----
brew "git"                        # Version control
brew "gh"                         # GitHub CLI
brew "jq"                         # JSON processor
brew "tree"                       # Directory tree visualizer
brew "wget"                       # HTTP downloader

# ---- Modern CLI replacements (Rust-based, drop-in upgrades) ----
brew "ripgrep"                    # Fast recursive grep (rg); respects .gitignore
brew "fd"                         # Modern find: intuitive syntax, parallel execution
brew "bat"                        # cat with syntax highlighting and git integration
brew "eza"                        # Modern ls: icons, git status, tree view
brew "zoxide"                     # Smarter cd: jumps to directories by partial name
brew "fzf"                        # Fuzzy finder: powers Ctrl+R, file pickers, etc.
brew "git-delta"                  # Syntax-highlighted git diffs
brew "lazygit"                    # Terminal UI for git
brew "btop"                       # Modern resource monitor (replaces top/htop)
brew "dust"                       # Visual disk usage (replaces du)
brew "tldr"                       # Simplified man pages with real examples
brew "atuin"                      # SQLite-backed shell history with search

# ---- Shell productivity ----
brew "starship"                   # Cross-shell prompt (actively maintained; replaces powerlevel10k)
brew "antidote"                   # Zsh plugin manager (fast, static-generated loader)

# ---- Language version manager ----
# Runtimes for Node.js, Python, Go are declared in .tool-versions.
# After `brew bundle`, run `asdf install` to fetch them.
brew "asdf"

# ---- Language-adjacent build tools ----
# Needed by some asdf plugins and native modules during compilation.
brew "coreutils"                  # GNU core utilities (required by asdf on macOS)
brew "openssl@3"                  # TLS library (Python, Node native modules)
brew "readline"                   # Line-editing library (Python build)
brew "xz"                         # Compression library (Python build)

# ---- Containers ----
# Docker Desktop provides both the Docker daemon and docker/docker-compose CLIs.
# All local databases (PostgreSQL, Redis, etc.) run as containers per your setup.
cask "docker-desktop"

# ---- Cloud tooling ----
cask "gcloud-cli"                 # gcloud, gsutil, bq (kubectl installed on demand)
                                  # Formerly the "google-cloud-sdk" formula; renamed + moved to cask in 2025.

# ---- Terminal emulator & editors ----
cask "ghostty"                    # Native GPU-accelerated terminal (replaces iTerm2 in 2026)
cask "visual-studio-code"         # Editor
cask "cursor"                     # AI-native code editor

# ---- Browsers ----
cask "google-chrome"

# ---- Productivity & utilities ----
cask "rectangle"                  # Window management (keyboard-driven tiling)
cask "1password"                  # Password manager
cask "appcleaner"                 # Clean app uninstalls
cask "maccy"                      # Clipboard history manager (Cmd+Shift+C)
cask "linearmouse"                # Mouse customization: extra buttons, per-device scroll/accel
                                  # Essential for third-party mice with side/extra buttons.
                                  # Fixes macOS's patchy handling of back/forward buttons.

# ---- API testing ----
cask "granola"                    # AI-powered notepad for meetings
cask "postman"                    # REST client & API testing

# ---- Developer fonts ----
# Nerd Fonts include glyphs required by Starship, eza icons, and modern TUI tools.
cask "font-jetbrains-mono-nerd-font"  # Recommended: primary coding font
cask "font-fira-code-nerd-font"       # Alternative with strong ligatures
