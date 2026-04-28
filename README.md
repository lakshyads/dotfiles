# macOS Developer Setup (2026)

A reproducible macOS development environment. Clone this repo onto a fresh Mac, run one script, and you get:

- A modern terminal (Ghostty) with an actively-maintained cross-shell prompt (Starship)
- Language runtimes pinned per-project via asdf (Node, Python, Go)
- Modern CLI tools (`ripgrep`, `fd`, `bat`, `eza`, `zoxide`, `fzf`, `atuin`, `lazygit`, `delta`, `btop`, `dust`, `tldr`)
- Editors: VS Code + Cursor + Claude Code
- Docker Desktop, Google Cloud SDK, GitHub CLI
- Everything wired together via `.zshrc`, Starship, Antidote, and a bootstrap script

---

## Table of Contents

- [Quick Start](#quick-start)
- [What the Setup Gives You](#what-the-setup-gives-you)
  - [Terminal & Shell](#terminal--shell)
  - [Modern CLI Tools](#modern-cli-tools-aliased-so-you-get-them-without-thinking)
  - [Fuzzy Finder Key Bindings](#fuzzy-finder-key-bindings)
  - [Language Runtimes (via asdf)](#language-runtimes-via-asdf)
  - [Applications Installed](#applications-installed)
- [Manual Steps (After `./setup.sh`)](#manual-steps-after-setupsh)
  - [1. Grant Accessibility Permissions](#1-grant-accessibility-permissions-one-time-per-app)
  - [2. Configure Git Identity](#2-configure-git-identity)
  - [3. Authenticate GitHub CLI](#3-authenticate-github-cli)
  - [4. Launch Docker Desktop Once](#4-launch-docker-desktop-once)
  - [5. Sign Into GUI Apps](#5-sign-into-gui-apps)
  - [6. Authenticate Cloud CLIs](#6-authenticate-cloud-clis-as-needed)
  - [7. Authenticate Claude Code](#7-authenticate-claude-code)
  - [8. Optional: Enable Atuin History Sync](#8-optional-enable-atuin-history-sync)
  - [9. Optional: Set Ghostty as Default Terminal](#9-optional-set-ghostty-as-default-terminal)
  - [10. Optional: Personalize Theme & Font](#10-optional-personalize-theme--font)
- [Daily Usage: Keybindings & Commands](#daily-usage-keybindings--commands)
  - [Ghostty (Terminal)](#ghostty-terminal)
  - [Shell (fzf / Atuin)](#shell-fzf--atuin)
  - [zoxide (jump anywhere)](#zoxide-jump-anywhere)
  - [Modern CLI essentials](#modern-cli-essentials)
  - [Language runtimes (asdf)](#language-runtimes-asdf)
- [Customization](#customization)
- [Updating Your Setup](#updating-your-setup)
  - [Update everything](#update-everything)
  - [Update just Homebrew packages](#update-just-homebrew-packages)
  - [Update Claude Code](#update-claude-code)
  - [Update asdf plugins](#update-asdf-plugins)
- [Troubleshooting](#troubleshooting)
  - [`./setup.sh` returns "permission denied"](#setupsh-returns-permission-denied)
  - ["command not found" on a tool that should exist](#command-not-found-on-a-tool-that-should-exist)
  - [Icons show as squares in Starship / eza](#icons-show-as-squares-in-starship--eza)
  - [Ghostty Quick Terminal doesn't respond](#ghostty-quick-terminal-doesnt-respond)
  - [SSH session looks broken](#ssh-session-looks-broken-vim--less-render-incorrectly)
  - [asdf says "No version is set"](#asdf-says-no-version-is-set-for-command-x)
  - [`brew bundle` fails with permissions errors](#brew-bundle-fails-with-permissions-errors)
  - [Atuin doesn't import my old history](#atuin-doesnt-import-my-old-history)
  - [Starting over on a single tool](#starting-over-on-a-single-tool)
- [Cheat Sheets & References](#cheat-sheets--references)
- [Repository Layout](#repository-layout)
- [Design Decisions (Short Version)](#design-decisions-short-version)

---

## Quick Start

On a fresh Mac:

```bash
# 1. macOS prompts for Xcode Command Line Tools on first `git` invocation.
#    If you want to trigger it explicitly:
xcode-select --install

# 2. Clone and bootstrap
git clone https://github.com/lakshyads/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x setup.sh        # first time only; see note below
./setup.sh
```

`setup.sh` is idempotent and safe to re-run. It installs Homebrew (if missing), everything in the `Brewfile`, language runtimes from `.tool-versions`, symlinks all config files, and sets up fzf key bindings.

When it finishes, open Ghostty, run `exec zsh`, and you're in the new environment.

To verify everything installed correctly in a new shell:

```bash
./verify.sh
```

This runs non-destructive smoke tests: checks every CLI tool resolves, every symlink is in place, every GUI app installed, language runtimes match `.tool-versions`, fonts are detected, and Git is configured. Exit 0 on success, 1 with a failure summary otherwise.

> **Why `chmod +x`?** Depending on how you cloned or downloaded the repo, the executable bit on `setup.sh` may not be preserved (macOS Gatekeeper strips it for quarantined files, and some git configs do too). Running `chmod +x setup.sh` once fixes it permanently. If you cloned via plain `git clone` into a trusted directory, it may already be executable and this step is a no-op.

<p align="right"><a href="#table-of-contents">↑ Back to top</a></p>

---

## What the Setup Gives You

Everything below works out of the box after `./setup.sh`. **No manual configuration required.**

### Terminal & Shell

- **Ghostty** with JetBrains Mono Nerd Font, Catppuccin theme (auto light/dark switching), 25M-line scrollback, and split keybindings
- **Quick Terminal** (Quake-style dropdown) bound to `Ctrl+\``; see manual steps for required permission
- **Zsh** with Antidote loading three plugins: autosuggestions, syntax highlighting, completions
- **Starship** prompt showing directory, git branch + status, active language version, and command duration
- **Atuin** replacing `Ctrl+R` with a full-screen SQLite-backed history search

### Modern CLI Tools (aliased, so you get them without thinking)

| Command | Maps to | What changes |
|---|---|---|
| `ls` | `eza --icons --group-directories-first` | Colors, icons, git status |
| `ll` | `eza -lah --git --icons` | Long format with git info |
| `lt` | `eza --tree --level=2 --icons` | Tree view |
| `cat` | `bat --paging=never` | Syntax highlighting + line numbers |
| `top` | `btop` | Modern resource monitor with graphs |
| `du` | `dust` | Tree-based disk usage |
| `g` | `git` | Shorter git invocation |
| `gs` / `gd` / `gl` | `git status/diff/log` | Common git shortcuts |
| `lg` | `lazygit` | Full git TUI |
| `reload` | `exec zsh` | Reload shell after config changes |

**Deliberately NOT aliased** (they have different flag semantics from their classics and would break scripts): `rg` (ripgrep), `fd`, `z` (zoxide). Use them as their own commands.

### Fuzzy Finder Key Bindings

- `Ctrl+R`: full-screen history search via Atuin
- `Ctrl+T`: fzf file picker (with bat preview)
- `Alt+C`: fzf directory picker (with eza tree preview)

### Language Runtimes (via asdf)

Declared in `.tool-versions`. Currently:

```
nodejs  24.15.0
python  3.13.13
golang  1.26.2
java    openjdk-25.0.2
```

Change versions by editing that file and running `asdf install`. Java versions use distributor-prefixed names (e.g. `openjdk-25.0.2`); run `asdf list all java` to browse available options.

### Applications Installed

Docker Desktop, VS Code, Cursor, Google Chrome, Rectangle, 1Password, AppCleaner, Maccy, LinearMouse. Plus Claude Code via the native auto-updating installer (not Homebrew).

<p align="right"><a href="#table-of-contents">↑ Back to top</a></p>

---

## Manual Steps (After `./setup.sh`)

These genuinely require human action, either because they need you to sign in, grant macOS permissions, or make personal choices. Work through them in order:

### 1. Grant Accessibility Permissions (one-time, per app)

Some apps need Accessibility permission to function. macOS will prompt on first launch, but you can pre-approve them:

**System Settings > Privacy & Security > Accessibility**, add:

- **Maccy**: required to read clipboard (app won't work without it)
- **Ghostty**: required only if you use the Quake-style Quick Terminal global hotkey (`Ctrl+\``)
- **Rectangle**: required for window snapping to work
- **LinearMouse**: required to intercept mouse events (side buttons, scroll customization)

### 2. Configure Git Identity

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
git config --global init.defaultBranch main

# Optional but useful
git config --global pull.rebase true
git config --global rebase.autoStash true
```

Full recommended git config and a workflow reference are in [`docs/git-cheatsheet.md`](docs/git-cheatsheet.md).

### 3. Authenticate GitHub CLI

```bash
gh auth login                   # follow prompts, choose SSH or HTTPS
```

### 4. Launch Docker Desktop Once

First launch triggers a macOS prompt to install a privileged helper. Click through it. After that, `docker` and `docker compose` work from any terminal.

Docker Desktop also appends a CLI completions block to `~/.zshrc` on first launch. This is already committed to the dotfiles `.zshrc`; don't let it get added a second time if you re-run setup on a machine where Docker Desktop has already launched.

### 5. Sign Into GUI Apps

- **1Password**: sign into your account so the CLI (`op`) can authenticate later
- **Chrome**: sign in, set as default browser if desired
- **Cursor / VS Code**: sign in for settings sync
- **Maccy**: no account, but enable "Launch at Login" in its preferences

### 6. Authenticate Cloud CLIs (as needed)

```bash
# Google Cloud
gcloud auth login
gcloud config set project <your-project-id>
gcloud auth application-default login   # for SDK libraries

# Skip if you don't use GCP
```

### 7. Authenticate Claude Code

```bash
claude          # first run opens browser for OAuth login
claude doctor   # verifies installation + auth
```

Requires a paid Anthropic account (Pro, Max, Team, Enterprise, or Console with API credits).

### 8. Optional: Enable Atuin History Sync

Atuin works fully offline by default. To sync history across machines (end-to-end encrypted):

```bash
atuin register -u <username> -e <email>
atuin key                    # save this somewhere safe (you'll need it on other machines)
```

Skip if you only use one Mac or don't want cloud sync.

### 9. Optional: Set Ghostty as Default Terminal

If you want `open .` and similar commands to open Ghostty instead of Terminal.app:

System Settings > Desktop & Dock > Scroll to "Default web browser / Default terminal". (Ghostty will offer to set itself as default on first launch.)

### 10. Optional: Personalize Theme & Font

The defaults are chosen carefully, but if you want to customize:

- **Ghostty theme:** edit `ghostty-config`, change the `theme = ...` line. Preview options with `ghostty +list-themes`.
- **Font:** the Brewfile installs both `font-jetbrains-mono-nerd-font` (default) and `font-fira-code-nerd-font`. Change `font-family` in `ghostty-config`.
- **Starship prompt:** edit `starship.toml`. See [starship.rs/presets](https://starship.rs/presets) for ready-made layouts.
- **Shell aliases:** edit `.zshrc` and run `reload`.

All configs live in this repo and are symlinked, so changes are preserved in git.

<p align="right"><a href="#table-of-contents">↑ Back to top</a></p>

---

## Daily Usage: Keybindings & Commands

Quick reference for what you'll actually use every day. Full references are in the cheat sheets.

### Ghostty (Terminal)

| Shortcut | Action |
|---|---|
| `Cmd+T` | New tab |
| `Cmd+W` | Close tab / split |
| `Cmd+1..9` | Jump to tab by number |
| `Cmd+D` | Split right |
| `Cmd+Shift+D` | Split down |
| `Cmd+Alt+arrows` | Navigate between splits |
| `Cmd+Shift+Enter` | Zoom/unzoom current split |
| `Cmd+Shift+,` | Reload config |
| `Ctrl+\`` | Toggle Quick Terminal dropdown (anywhere on macOS) |

### Shell (fzf / Atuin)

| Shortcut | Action |
|---|---|
| `Ctrl+R` | Search shell history (Atuin full-screen UI) |
| `Ctrl+T` | Fuzzy pick a file (preview via bat) |
| `Alt+C` | Fuzzy pick a directory (preview via eza) |
| `→` (right arrow) | Accept autosuggestion |

> **On Mac, `Alt` is the same key as `Option` (⌥).** Tool documentation (fzf, readline) uses the Alt label historically; press the key labeled Option on your keyboard.

### zoxide (jump anywhere)

```bash
z proj              # jumps to most-visited dir matching "proj"
z proj frontend     # narrows by multiple terms
zi                  # interactive picker
z -                 # previous directory
```

### Modern CLI essentials

```bash
# Search code
rg "TODO" --type ts
rg -i "error" -C 3

# Find files
fd -e md                         # all .md files
fd --type d config               # directories named "config"

# Git
lg                               # full TUI
gl                               # log --oneline --graph --decorate -20
gs                               # status

# View files
bat README.md                    # syntax-highlighted cat
eza -lah --git                   # ls with git info and icons

# Disk / resources
dust                             # tree-based du
btop                             # process monitor
```

For full references: [`docs/modern-cli-cheatsheet.md`](docs/modern-cli-cheatsheet.md) covers ripgrep, fd, bat, eza, fzf, atuin, delta, dust, btop, tldr with usage patterns and composition examples. For the lazygit TUI specifically: [`docs/lazygit-cheatsheet.md`](docs/lazygit-cheatsheet.md).

### Language runtimes (asdf)

```bash
asdf current                     # show active versions for everything
asdf install                     # install everything in .tool-versions
asdf set nodejs 24.15.0           # pin a version in current dir
asdf list all python 3.12        # show installable 3.12.x versions
```

For full command reference: [`docs/asdf-cheatsheet.md`](docs/asdf-cheatsheet.md).

<p align="right"><a href="#table-of-contents">↑ Back to top</a></p>

---

## Customization

This repo is meant to be forked and personalized. The files worth editing:

| File | What it controls |
|---|---|
| `Brewfile` | What gets installed via Homebrew. Add/remove lines, run `brew bundle`. |
| `.tool-versions` | Language runtime versions. Edit and run `asdf install`. |
| `.zshrc` | Aliases, env vars, tool integration. Run `reload` after editing. |
| `.zsh_plugins.txt` | Zsh plugins loaded by Antidote. |
| `starship.toml` | Prompt appearance. |
| `ghostty-config` | Terminal appearance and keybindings. Reload with `Cmd+Shift+,`. |
| `linearmouse.json` | Mouse settings (side buttons, scroll direction, acceleration). Edit via the LinearMouse GUI; changes write back to the file automatically. |
| `setup.sh` | Bootstrap steps. Only touch if you add new tools needing custom setup. |

After any changes, commit them to your dotfiles repo. Other machines pick up changes with `git pull && ./setup.sh`.

<p align="right"><a href="#table-of-contents">↑ Back to top</a></p>

---

## Updating Your Setup

### Update everything

```bash
cd ~/dotfiles
git pull
brew update && brew upgrade     # Homebrew packages
brew bundle                      # ensure new Brewfile entries are installed
asdf install                     # ensure new .tool-versions are installed
brew cleanup                     # reclaim disk space
```

### Update just Homebrew packages

```bash
brew update && brew upgrade
brew cleanup
```

### Update Claude Code

It auto-updates via the native installer. If you want to verify or force update:

```bash
claude doctor
```

### Update asdf plugins

```bash
asdf plugin update --all
```

<p align="right"><a href="#table-of-contents">↑ Back to top</a></p>

---

## Troubleshooting

### `./setup.sh` returns "permission denied"

The executable bit wasn't preserved. One-time fix:

```bash
chmod +x setup.sh
./setup.sh
```

To make the fix permanent so other machines cloning the repo don't hit this, commit the mode change:

```bash
chmod +x setup.sh
git add setup.sh              # `git status` should show "mode change 100644 → 100755"
git commit -m "chore: make setup.sh executable"
git push
```

### "command not found" on a tool that should exist

1. Did you run `./setup.sh`? It symlinks `.zshrc`; without that, aliases and PATH aren't set.
2. Did you restart your shell after install? Run `exec zsh` or open a new tab.
3. Check the tool is actually installed: `brew list | grep <tool>`.
4. For language tools (node, python, go): run `asdf current` to verify the active version is installed.

### Icons show as squares in Starship / eza

Your terminal isn't using a Nerd Font. Check `ghostty-config`:

```
font-family = JetBrainsMono Nerd Font
```

The spaces matter. See [`docs/ghostty-cheatsheet.md`](docs/ghostty-cheatsheet.md#themes--fonts) for details.

### Ghostty Quick Terminal doesn't respond

Accessibility permission not granted. Go to System Settings > Privacy & Security > Accessibility, add Ghostty, restart Ghostty.

### SSH session looks broken (vim / less render incorrectly)

The remote host doesn't have Ghostty's terminfo. Your `ghostty-config` already sets `term = xterm-256color` to avoid this, but if you removed that line, re-add it.

### asdf says "No version is set for command X"

The `.tool-versions` file references a version that isn't installed yet:

```bash
asdf install
```

See [`docs/asdf-cheatsheet.md`](docs/asdf-cheatsheet.md#troubleshooting) for deeper issues.

### `brew bundle` fails with permissions errors

Usually means Homebrew itself needs repair:

```bash
sudo chown -R $(whoami) /opt/homebrew
brew doctor
```

See [`docs/homebrew-cheatsheet.md`](docs/homebrew-cheatsheet.md#common-pitfalls).

### Atuin doesn't import my old history

```bash
atuin import auto                # auto-detects zsh_history and imports
atuin stats                      # verify history count went up
```

### Starting over on a single tool

```bash
# Reinstall a Homebrew cask
brew reinstall --cask ghostty

# Reset an asdf tool
asdf uninstall python 3.13.13
asdf install python 3.13.13

# Reload shell config without restarting
reload
```

<p align="right"><a href="#table-of-contents">↑ Back to top</a></p>

---

## Cheat Sheets & References

Full command references for the tools that get the most daily use. These live in `docs/` so you can open them in-repo rather than fishing through web docs:

- **[Homebrew cheat sheet](docs/homebrew-cheatsheet.md)**: install, daily commands, Brewfile workflows, FAQ, common pitfalls
- **[asdf cheat sheet](docs/asdf-cheatsheet.md)**: plugin management, version commands, `.tool-versions` format, CI integration, troubleshooting
- **[Ghostty cheat sheet](docs/ghostty-cheatsheet.md)**: default keybindings, config syntax, action reference, SSH terminfo fixes, themes and fonts
- **[Git cheat sheet](docs/git-cheatsheet.md)**: daily workflow commands, branching, rebasing, undoing mistakes, stash, tags, `.gitignore` essentials, troubleshooting
- **[Lazygit cheat sheet](docs/lazygit-cheatsheet.md)**: panel navigation, default keybindings, line-staging, interactive rebase workflows, custom commands
- **[Modern CLI tools cheat sheet](docs/modern-cli-cheatsheet.md)**: ripgrep, fd, bat, eza, zoxide, fzf, atuin, delta, dust, btop, tldr. Usage per tool plus composition examples
- **[Claude Code cheat sheet](docs/claude-code-cheatsheet.md)**: CLI flags, slash commands, keyboard shortcuts, permission modes, CLAUDE.md, hooks, MCP, subagents, models and cost
- **[Cursor CLI cheat sheet](docs/cursor-cli-cheatsheet.md)**: agent modes (Agent/Plan/Ask), slash commands, cloud handoff, MCP integration, rules and skills, subagents

Each is written as a skimmable reference, not a tutorial. Use them when you need to look something up.

<p align="right"><a href="#table-of-contents">↑ Back to top</a></p>

---

## Repository Layout

```
dotfiles/
├── README.md                  # this file (orientation + daily reference)
├── setup.sh                   # one-command bootstrap (idempotent)
├── verify.sh                  # end-to-end smoke test (run after setup.sh)
├── Brewfile                   # Homebrew packages (formulae + casks)
├── .tool-versions             # asdf runtime versions (Node, Python, Go)
├── .zshrc                     # shell config (aliases, tool integration)
├── .zsh_plugins.txt           # Antidote plugin list
├── starship.toml              # Starship prompt config
├── ghostty-config             # Ghostty terminal config
├── linearmouse.json           # Mouse customization (side buttons, acceleration)
└── docs/
    ├── homebrew-cheatsheet.md
    ├── asdf-cheatsheet.md
    ├── ghostty-cheatsheet.md
    ├── git-cheatsheet.md
    ├── lazygit-cheatsheet.md
    ├── modern-cli-cheatsheet.md
    ├── claude-code-cheatsheet.md
    └── cursor-cli-cheatsheet.md
```

<p align="right"><a href="#table-of-contents">↑ Back to top</a></p>

---

## Design Decisions (Short Version)

A few choices that drive the rest of the setup. Full context is in the cheat sheets, but the gist:

- **Ghostty over iTerm2**: GPU-accelerated native macOS rendering, ~3× faster than iTerm2, zero-config
- **Starship over Powerlevel10k**: P10k is on life support; Starship is actively maintained and cross-shell
- **Antidote over Oh My Zsh**: faster startup, picks exactly what you need (OMZ is also defensible if you want its catalog)
- **asdf over pyenv/nvm/rbenv**: one tool replaces all of them; single `.tool-versions` file per project
- **Zsh kept as login shell**: POSIX-compatible (unlike Fish) and already the macOS default
- **Claude Code via native installer, not Homebrew**: the native installer auto-updates; the brew cask does not
- **Docker for all local databases**: Brewfile intentionally omits `postgresql` / `redis` so they don't conflict with container-based local environments

<p align="right"><a href="#table-of-contents">↑ Back to top</a></p>
