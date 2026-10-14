# Installed Software Inventory

> **Source of truth per install method:**
> - Every CLI tool (formulae) and GUI app (casks): `configuration.nix`'s `homebrew` block
> - Global npm CLIs: `home/npm-globals.txt` (installed by `./npm-globals.sh`)
> - Config only (zsh, Starship prompt, git config, symlinks) plus fonts and zsh completions: `home.nix`
> - Language runtime versions: `.tool-versions`
> - Self-updating native installers (Claude Code `claude`, Cursor `agent`): `bootstrap.sh`
>
> Update this file whenever any of the above change.

---

## Bootstrap (installed before everything else)

| Tool | Installed via | Notes |
|------|---------------|-------|
| Xcode Command Line Tools | `xcode-select --install` | Required for `git` and native compilation on macOS; installed by `bootstrap.sh` |
| Determinate Nix | `curl \| sh` (install.determinate.systems) | Nix package manager; installed by `bootstrap.sh` |
| Homebrew | Adopted by nix-homebrew (`autoMigrate = true` in `configuration.nix`) | Package manager for every CLI tool and GUI app; management itself is now declared in `configuration.nix`, not a separate bootstrap step |

---

## GUI Applications

All declared in `configuration.nix`'s `homebrew.casks` (applied via `darwin-rebuild switch`, i.e. `./bootstrap.sh` or `./rebuild.sh`).

| App | Installed via | Category | Notes |
|-----|---------------|----------|-------|
| Ghostty | `configuration.nix` (homebrew.casks) | Terminal | GPU-accelerated; replaces iTerm2 |
| WezTerm | `configuration.nix` (homebrew.casks) | Terminal | GPU-accelerated, cross-platform terminal emulator |
| Visual Studio Code | `configuration.nix` (homebrew.casks) | Editor | |
| Cursor | `configuration.nix` (homebrew.casks) | Editor | AI-native code editor. Cursor can read personal rules from `~/.cursor/rules/*.mdc`; `home/AGENTS.md` is deliberately not wired there. It does scan `~/.agents/skills` |
| Docker Desktop | `configuration.nix` (homebrew.casks) | Containers | Provides `docker` and `docker compose` CLIs — see [Docker cheat sheet](cheatsheets/docker-cheatsheet.md) |
| Google Chrome | `configuration.nix` (homebrew.casks) | Browser | |
| Firefox | `configuration.nix` (homebrew.casks) | Browser | |
| ChatGPT Atlas | `configuration.nix` (homebrew.casks) | Browser | OpenAI's browser with ChatGPT built in; requires arm64 + macOS 14 |
| Google Cloud CLI | `configuration.nix` (homebrew.casks) | Cloud | Includes `gcloud`, `gsutil`, `bq`; kubectl installed on demand |
| Rectangle | `configuration.nix` (homebrew.casks) | Productivity | Keyboard-driven window tiling |
| AppCleaner | `configuration.nix` (homebrew.casks) | Productivity | Clean app uninstalls |
| Maccy | `configuration.nix` (homebrew.casks) | Productivity | Clipboard history (Cmd+Shift+C) |
| LinearMouse | `configuration.nix` (homebrew.casks) | Productivity | Mouse customization: side buttons, scroll, acceleration. Config write-back handled by `home.nix`'s `mkOutOfStoreSymlink` + `home.activation.backupLinearMouseConfig` |
| OpenSuperWhisper | `configuration.nix` (homebrew.casks) | Productivity | Open-source AI voice-to-text dictation (system-wide) |
| Obsidian | `configuration.nix` (homebrew.casks) | Productivity | Markdown-based knowledge base / note-taking. `docs/cheatsheets/` doubles as a vault folder — see `home.nix`'s `Documents/workspace/my-matrix/a-utils/cheatsheets` symlink |
| Granola | `configuration.nix` (homebrew.casks) | Productivity | AI-powered notepad for meetings |
| Postman | `configuration.nix` (homebrew.casks) | API Testing | REST client |
| Whimsical | `configuration.nix` (homebrew.casks) | Productivity | Collaboration and diagramming tool |
| Baby Menu | `configuration.nix` (homebrew.casks: `kunchenguid/tap/baby-menu`) | Productivity | Agent-editable macOS menu bar — ask Claude/Codex (or a custom ACP agent) to add widgets. Extensions, `preferences.json`, and `agents.json` are edit-in-place via `home.nix`'s `mkOutOfStoreSymlink` + `home.activation.backupBabyMenuConfig` (`home/.baby-menu/`); SQLite DB and caches stay machine-local under `~/.baby-menu/` |
| Claude (desktop) | `configuration.nix` (homebrew.casks: `claude`) | AI | Anthropic Claude desktop app |
| Codex (desktop) | `configuration.nix` (homebrew.casks: `codex-app`) | AI | OpenAI Codex desktop app for managing coding agents; global instructions symlinked from `home/AGENTS.md` to `~/.codex/AGENTS.md` |
---

## CLI Tools & Utilities

### Version control & core utilities

Installed via `configuration.nix` (homebrew.brews), unless noted otherwise.

| Tool | Description |
|------|-------------|
| `git` | Version control; config written to `~/.config/git/config` by `home.nix`'s `programs.git` (`package = null`, so the binary is Homebrew's) |
| `gh` | GitHub CLI |
| `jq` | JSON processor |
| `tree` | Directory tree visualizer |
| `wget` | HTTP downloader |
| `nvim` (neovim) | Modal text editor — see `home/.config/nvim/` for the full lazy.nvim config |
| `tree-sitter` (formula `tree-sitter-cli`) | Parser generator CLI; nvim-treesitter shells out to it to compile Neovim's syntax parsers |

### Modern CLI replacements

Installed via `configuration.nix` (homebrew.brews), unless noted otherwise.

| Tool | Replaces | Description |
|------|----------|-------------|
| `rg` (ripgrep) | `grep` | Fast recursive search; respects `.gitignore` |
| `fd` | `find` | Intuitive file finder; parallel, regex by default |
| `bat` | `cat` | Syntax-highlighted file viewer with line numbers |
| `eza` | `ls` | Modern listing with icons, git status, tree view |
| `zoxide` (`z`) | `cd` | Learns habits; jump to dirs by partial name — shell init in `home.nix`'s `programs.zsh.initContent` |
| `fzf` | — | Fuzzy finder for history, files, branches, processes — shell integration in `home.nix`'s `programs.zsh.initContent` |
| `delta` | `diff` pager | Syntax-highlighted, side-by-side git diffs (formula `git-delta`); pager config declared in `home.nix`'s `programs.git.settings` (home-manager, applied to `~/.config/git/config`) |
| `lazygit` (`lg`) | — | Full terminal UI for git |
| `btop` | `top` / `htop` | Modern resource monitor with graphs |
| `dust` | `du` | Tree-based disk usage visualizer |
| `tldr` | `man` (common cases) | Simplified man pages with real examples (formula `tlrc`; the `tldr` formula is disabled) |
| `atuin` | `~/.zsh_history` | SQLite-backed shell history with search — shell init in `home.nix`'s `programs.zsh.initContent` |

### AI coding CLIs

| Tool | Installed via | Description |
|------|---------------|-------------|
| `claude` | Anthropic's native installer (`bootstrap.sh`, into `~/.local/bin`) | Anthropic Claude Code CLI. Auto-updates in the background (channel: `autoUpdatesChannel` in `home/.claude/settings.json`); `claude update` on the spot. Global config (`CLAUDE.md` from `home/AGENTS.md`, `settings.json`, `statusline-command.sh`) symlinked via home-manager into `~/.claude/` |
| `codex` | `configuration.nix` (homebrew.casks: `codex`) | OpenAI Codex CLI — coding agent in terminal |
| `opencode` | `configuration.nix` (homebrew.brews) | AI coding agent, built for the terminal |
| `pi` | npm (`@earendil-works/pi-coding-agent` in `home/npm-globals.txt`, installed by `./npm-globals.sh` into `~/.local/share/npm-global`) | Minimal coding agent harness ([pi.dev](https://pi.dev)); global instructions at `~/.pi/agent/AGENTS.md` |
| `agent` / `cursor-agent` | Cursor's native installer (`bootstrap.sh`, into `~/.local/bin`) | Cursor's agent CLI; self-updating, `agent update` on the spot — aliased to `aa` in `home.nix`'s `programs.zsh.shellAliases` |

#### Agent-facing npm CLIs

All declared in `home/npm-globals.txt` and installed by `./npm-globals.sh` into `~/.local/share/npm-global`.

| Tool | Description |
|------|-------------|
| `gh-axi`, `lavish-axi`, `tasks-axi`, `quota-axi`, `chrome-devtools-axi` | Agent-facing CLIs; the Claude Code `SessionStart` hooks in `home/.claude/settings.json` call these |
| `chrome-devtools-mcp` | Chrome DevTools MCP server for agents |
| `acpx` | Agent Client Protocol (ACP) CLI |

#### Shared agent skills

Claude Code, Codex CLI, Cursor, OpenCode, and Pi all read the same open `SKILL.md` format (YAML frontmatter with `name`/`description`, then markdown instructions). Codex, Cursor, OpenCode, and Pi scan `~/.agents/skills` natively; Claude Code only reads its own `~/.claude/skills`, so `home.nix` symlinks each skill into both directories from one canonical copy in this repo's `home/skills/<name>/`.

| Skill | Canonical source | Symlinked into |
|-------|-------------------|-----------------|
| `smell` | `home/skills/smell/SKILL.md` | `~/.agents/skills/smell`, `~/.claude/skills/smell` |
| `commit-message` | `home/skills/commit-message/SKILL.md` | `~/.agents/skills/commit-message`, `~/.claude/skills/commit-message` |
| `pr-description` | `home/skills/pr-description/SKILL.md` | `~/.agents/skills/pr-description`, `~/.claude/skills/pr-description` |
| `architecture-plan` | `home/skills/architecture-plan/SKILL.md` | `~/.agents/skills/architecture-plan`, `~/.claude/skills/architecture-plan` |

Third-party skills are declared in `home/agent-skills.txt` and installed by `./agent-skills.sh` with `npx skills add <source> --skill <name> -g`: a real copy in `~/.agents/skills`, symlinked into `~/.claude/skills`. `./update.sh` runs `npx skills update -g`.

| Skill | Source repo | Notes |
|-------|-------------|-------|
| `lavish` | `kunchenguid/lavish-axi` | Discovery stub for the `lavish-axi` CLI, which it runs via `npx -y lavish-axi` |
| `web-design-guidelines` | `vercel-labs/agent-skills` | Fetches its rule set from GitHub at runtime |
| `vercel-react-best-practices` | `vercel-labs/agent-skills` | |

Skills generated by other tools (e.g. `no-mistakes`) aren't managed by this repo.

See [git cheatsheet — Code smell review](cheatsheets/git-cheatsheet.md), [git cheatsheet — Commit message conventions](cheatsheets/git-cheatsheet.md), and [git cheatsheet — Pull request description conventions](cheatsheets/git-cheatsheet.md) for usage.

### Terminal multiplexing

| Tool | Installed via | Description |
|------|---------------|-------------|
| `herdr` | `configuration.nix` (homebrew.brews) | Agent multiplexer for the terminal (tmux-style `Ctrl+B` prefix bindings) — config in `home/.config/herdr/config.toml` |

### Cloud, infrastructure & payments CLIs

| Tool | Installed via | Description |
|------|---------------|-------------|
| `terraform` | `configuration.nix` (homebrew.brews, tap: `hashicorp/tap`) | Infrastructure-as-code CLI |
| `stripe` | `configuration.nix` (homebrew.brews, tap: `stripe/stripe-cli`) | Stripe CLI: webhook testing, API calls |
| `firebase` | npm (`firebase-tools` in `home/npm-globals.txt`) | Firebase CLI |
| `posthog-cli` | npm (`@posthog/cli` in `home/npm-globals.txt`) | PostHog CLI |

### Shell productivity

| Tool | Installed via | Description |
|------|---------------|-------------|
| `starship` | `configuration.nix` (homebrew.brews) | Cross-shell prompt (replaces Powerlevel10k); config generated by `home.nix`'s `xdg.configFile."starship.toml"` |

Zsh plugin management (autosuggestions, syntax-highlighting, completion) is native to home-manager now — see [Zsh plugins](#zsh-plugins) below. Antidote and `.zsh_plugins.txt` were retired.

### Zsh plugins

**Retired.** Antidote (the plugin manager) and `.zsh_plugins.txt` no longer exist. Their functionality is replaced by home-manager's native `programs.zsh` toggles, declared directly in `home.nix`:

| Former plugin | Now |
|--------|---------|
| `zsh-users/zsh-autosuggestions` | `programs.zsh.autosuggestion.enable = true` |
| `zsh-users/zsh-syntax-highlighting` | `programs.zsh.syntaxHighlighting.enable = true` |
| `zsh-users/zsh-completions` | `home.packages`' `zsh-completions` + `programs.zsh.enableCompletion = true`, with the extra completion fpath wired in `programs.zsh.initContent` |

### Language version manager

| Tool | Installed via | Description |
|------|---------------|-------------|
| `asdf` | `configuration.nix` (homebrew.brews) | Manages language runtimes via `.tool-versions`. Kept Homebrew-managed and outside Nix by design — see README's Design Decisions. |

### Post-install integration

| Tool | Installed via | Description |
|------|---------------|-------------|
| fzf key bindings | `source <(fzf --zsh)` in `home.nix`'s `programs.zsh.initContent` | Wires `Ctrl+T`, `Ctrl+R`, `Alt+C` into Zsh — no separate install script needed anymore |

### Build & compilation support

| Tool | Installed via | Required by |
|------|---------------|-------------|
| `coreutils` | `configuration.nix` (homebrew.brews) | asdf on macOS |
| `openssl@3` | `configuration.nix` (homebrew.brews) | Python and Node native modules |
| `readline` | `configuration.nix` (homebrew.brews) | Python build |
| `xz` | `configuration.nix` (homebrew.brews) | Python build |

### Developer fonts

Installed via `home.nix`'s `home.packages` (Nix nerd-fonts derivations), not Homebrew casks.

| Font | Use |
|------|-----|
| Hack Nerd Font | Primary system font (Ghostty + WezTerm default) |
| JetBrains Mono Nerd Font | Alternative — see README "Personalize Theme & Font" for how to switch |
| Fira Code Nerd Font | Alternative with strong ligatures |

---

## Language Runtimes

Managed by **asdf**. Versions are declared in **`.tool-versions`** — that is the only source of truth for version numbers. Edit that file and run `./bootstrap.sh` (or `asdf install` directly) to add or change a version. Deliberately kept outside Nix's management — see README's Design Decisions for why.

| Language | `.tool-versions` key |
|----------|----------------------|
| Node.js | `nodejs` |
| Python | `python` |
| Go | `golang` |
| Java | `java` |
