# Installed Software Inventory

> **Source of truth per install method:**
> - Packages: `Brewfile` (formulae + casks)
> - Language versions: `.tool-versions`
> - Non-Homebrew installs: `setup.sh`
>
> Update this file whenever any of the above change.

---

## Bootstrap (installed before Homebrew)

| Tool | Installed via | Notes |
|------|---------------|-------|
| Xcode Command Line Tools | `xcode-select --install` | Required for `git` and native compilation on macOS |
| Homebrew | `curl \| bash` (official install.sh) | Package manager; bootstrapped first by `setup.sh` |

---

## GUI Applications

All installed via `brew install --cask` unless noted otherwise.

| App | Installed via | Category | Notes |
|-----|---------------|----------|-------|
| Ghostty | `brew install --cask` | Terminal | GPU-accelerated; replaces iTerm2 |
| Visual Studio Code | `brew install --cask` | Editor | |
| Cursor | `brew install --cask` | Editor | AI-native code editor |
| Docker Desktop | `brew install --cask` | Containers | Provides `docker` and `docker compose` CLIs |
| Google Chrome | `brew install --cask` | Browser | |
| Google Cloud CLI | `brew install --cask` | Cloud | Includes `gcloud`, `gsutil`, `bq`; kubectl installed on demand |
| Rectangle | `brew install --cask` | Productivity | Keyboard-driven window tiling |
| 1Password | `brew install --cask` | Productivity | Password manager |
| AppCleaner | `brew install --cask` | Productivity | Clean app uninstalls |
| Maccy | `brew install --cask` | Productivity | Clipboard history (Cmd+Shift+C) |
| LinearMouse | `brew install --cask` | Productivity | Mouse customization: side buttons, scroll, acceleration |
| Granola | `brew install --cask` | Productivity | AI-powered notepad for meetings |
| Postman | `brew install --cask` | API Testing | REST client |
| Claude Code | `curl \| bash` (claude.ai/install.sh) | AI / CLI | Native auto-updating installer — **not** via Homebrew |

---

## CLI Tools & Utilities

All installed via `brew install` (formula) unless noted otherwise.

### Version control & core utilities

| Tool | Description |
|------|-------------|
| `git` | Version control |
| `gh` | GitHub CLI |
| `jq` | JSON processor |
| `tree` | Directory tree visualizer |
| `wget` | HTTP downloader |

### Modern CLI replacements

| Tool | Replaces | Description |
|------|----------|-------------|
| `rg` (ripgrep) | `grep` | Fast recursive search; respects `.gitignore` |
| `fd` | `find` | Intuitive file finder; parallel, regex by default |
| `bat` | `cat` | Syntax-highlighted file viewer with line numbers |
| `eza` | `ls` | Modern listing with icons, git status, tree view |
| `zoxide` (`z`) | `cd` | Learns habits; jump to dirs by partial name |
| `fzf` | — | Fuzzy finder for history, files, branches, processes |
| `delta` | `diff` pager | Syntax-highlighted, side-by-side git diffs |
| `lazygit` (`lg`) | — | Full terminal UI for git |
| `btop` | `top` / `htop` | Modern resource monitor with graphs |
| `dust` | `du` | Tree-based disk usage visualizer |
| `tldr` | `man` (common cases) | Simplified man pages with real examples |
| `atuin` | `~/.zsh_history` | SQLite-backed shell history with search |

### Shell productivity

| Tool | Description |
|------|-------------|
| `starship` | Cross-shell prompt (replaces Powerlevel10k) |
| `antidote` | Zsh plugin manager (fast, static-generated loader) |

### Zsh plugins

Loaded by Antidote. Plugin list is declared in **`.zsh_plugins.txt`** — that is the only place plugins are defined.

| Plugin | Purpose |
|--------|---------|
| `zsh-users/zsh-autosuggestions` | Inline history suggestions (right arrow to accept) |
| `zsh-users/zsh-completions` | Extra completions for git, docker, kubectl, etc. |
| `zsh-users/zsh-syntax-highlighting` | Live syntax highlighting as you type (must load last) |

### Language version manager

| Tool | Description |
|------|-------------|
| `asdf` | Manages language runtimes via `.tool-versions` |

### Post-install integration

| Tool | Installed via | Description |
|------|---------------|-------------|
| fzf key bindings | `fzf/install` script (run by `setup.sh`) | Wires `Ctrl+T`, `Ctrl+R`, `Alt+C` into Zsh |

### Build & compilation support

| Tool | Required by |
|------|-------------|
| `coreutils` | asdf on macOS |
| `openssl@3` | Python and Node native modules |
| `readline` | Python build |
| `xz` | Python build |

### Developer fonts

| Font | Installed via | Use |
|------|---------------|-----|
| JetBrains Mono Nerd Font | `brew install --cask` | Primary coding font (default in Ghostty) |
| Fira Code Nerd Font | `brew install --cask` | Alternative with strong ligatures |

---

## Language Runtimes

Managed by **asdf**. Versions are declared in **`.tool-versions`** — that is the only source of truth for version numbers. Edit that file and run `asdf install` to add or change a version.

| Language | `.tool-versions` key |
|----------|----------------------|
| Node.js | `nodejs` |
| Python | `python` |
| Go | `golang` |
| Java | `java` |
