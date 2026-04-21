# Modern CLI Tools Cheat Sheet

A reference for the modern command-line tools in this setup: the Rust-based replacements for classic Unix tools plus a few new additions that don't have classic equivalents. Organized by task rather than by tool, so you can look up "how do I search files" without needing to remember which tool does it.

All tools below are installed via the `Brewfile`. See [`homebrew-cheatsheet.md`](homebrew-cheatsheet.md) if you need to install manually.

---

## Table of Contents

- [Tool Inventory](#tool-inventory)
- [Searching Code & Text (ripgrep)](#searching-code--text-ripgrep)
- [Finding Files (fd)](#finding-files-fd)
- [Viewing Files (bat)](#viewing-files-bat)
- [Listing Files (eza)](#listing-files-eza)
- [Jumping to Directories (zoxide)](#jumping-to-directories-zoxide)
- [Fuzzy Finding (fzf)](#fuzzy-finding-fzf)
- [Shell History (atuin)](#shell-history-atuin)
- [Git Diffs (delta)](#git-diffs-delta)
- [Disk Usage (dust)](#disk-usage-dust)
- [Resource Monitoring (btop)](#resource-monitoring-btop)
- [Quick Docs (tldr)](#quick-docs-tldr)
- [Composing Tools Together](#composing-tools-together)
- [Speed Comparison](#speed-comparison)

---

## Tool Inventory

| Tool | Replaces | One-line description |
|---|---|---|
| **ripgrep** (`rg`) | `grep` | Recursive code search, respects `.gitignore`, 10-100× faster |
| **fd** | `find` | Intuitive file finder, parallel, regex by default |
| **bat** | `cat` | Syntax-highlighted file viewer with line numbers |
| **eza** | `ls` | Modern directory listing with icons, git status, tree view |
| **zoxide** (`z`) | `cd` | Learns your habits; jump to any visited dir with a partial name |
| **fzf** | (new) | Fuzzy finder for anything (history, files, git branches, processes) |
| **atuin** | `~/.zsh_history` | SQLite-backed shell history with search and optional sync |
| **delta** | `diff` / `git diff` pager | Syntax-highlighted, side-by-side git diffs |
| **dust** | `du` | Tree-based disk usage visualizer |
| **btop** | `top` / `htop` | Modern resource monitor with graphs |
| **tldr** | `man` (for common cases) | Simplified man pages with real examples |

The `.zshrc` in this setup already aliases `ls`, `cat`, `top`, `du`. The rest you use as their own commands (`rg`, `fd`, `z`, `bat`, etc.), deliberately NOT aliased to their classics because flag semantics differ and aliasing breaks scripts.

---

## Searching Code & Text (ripgrep)

```bash
# Basic search in current directory (recursive by default)
rg "TODO"
rg "function login"

# Case-insensitive (smart-case: lowercase query = case-insensitive)
rg -i "Error"
rg "Error"                # case-sensitive because query has uppercase

# Search specific file types
rg "useState" --type js
rg "useState" -t ts       # shorthand
rg --type-list            # list all supported types

# Search by file glob
rg "TODO" -g "*.md"
rg "TODO" -g "!node_modules"      # exclude pattern

# Search hidden files (ripgrep skips them by default)
rg "token" --hidden

# Ignore .gitignore for this search
rg "secret" --no-ignore

# Show context around matches
rg "error" -C 3           # 3 lines before and after
rg "error" -B 2 -A 5      # 2 before, 5 after

# Limit results
rg "TODO" -m 5            # stop after 5 matches per file

# Count matches only
rg "TODO" -c              # count per file
rg "TODO" --count-matches  # total match count

# Only show filenames with matches
rg "TODO" -l

# Find where something is defined (word boundary)
rg -w "handleLogin"

# Replace (preview only; rg doesn't write)
rg "oldName" --replace "newName"

# Search inside compressed files
rg -z "error" logs.tar.gz
```

### Power combos

```bash
# Search only staged files
rg "TODO" $(git diff --cached --name-only)

# Search with fzf-interactive selection of matches
rg --line-number "TODO" | fzf

# Config file for default options
cat > ~/.ripgreprc <<EOF
--hidden
--follow
--glob=!.git/*
--glob=!node_modules/*
--smart-case
EOF
export RIPGREP_CONFIG_PATH=~/.ripgreprc
```

---

## Finding Files (fd)

```bash
# Basic usage
fd pattern                # fuzzy filename match
fd "^test.*\.js$"         # regex (default behavior)

# By extension
fd -e md                  # all .md files
fd -e py -e pyx           # multiple extensions

# By type
fd -t f pattern           # files only
fd -t d pattern           # directories only
fd -t l                   # symbolic links
fd -t x                   # executables

# Include hidden files (skipped by default)
fd -H pattern
fd --hidden pattern

# Don't respect .gitignore
fd --no-ignore pattern

# Search from a specific directory
fd pattern ~/projects
fd pattern src/

# Limit depth
fd pattern -d 2           # only 2 levels deep

# Modified recently
fd --changed-within 1d pattern      # last 24 hours
fd --changed-within 1w              # last week
fd --changed-before 1mo             # older than 1 month

# Execute a command on each match
fd -e log -x rm {}        # delete all .log files
fd -e png -x convert {} {.}.webp     # convert PNG to WebP
fd . -t f -x wc -l {}     # line count for every file

# Size filters
fd --size +1M             # larger than 1MB
fd --size -100k           # smaller than 100KB
```

**Gotcha:** fd uses regex by default, not glob. If you want glob, use `-g`:

```bash
fd -g "*.test.ts"
```

---

## Viewing Files (bat)

```bash
# Basic
bat file.js               # with syntax highlighting and line numbers

# Plain output (for piping)
bat -p file.js
bat --plain file.js
bat -pp file.js           # plain AND no paging

# Multiple files
bat *.md

# Pipe into bat
curl -s api.example.com/data | bat -l json

# Line range
bat -r 10:20 file.js      # lines 10-20
bat -r :50 file.js        # first 50 lines
bat -r 100: file.js       # from line 100 to end

# Highlight specific lines
bat -H 15 file.js         # highlight line 15

# Different theme
bat --theme=TwoDark file.js
bat --list-themes         # see all themes

# Show non-printable characters
bat -A file.txt           # for debugging file content

# Use as a pager (replaces less for man pages)
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
```

### Config file

```bash
mkdir -p "$(bat --config-dir)"
cat > "$(bat --config-file)" <<EOF
--theme="TwoDark"
--style="numbers,changes,header"
--paging=auto
EOF
```

---

## Listing Files (eza)

The setup aliases `ls`, `ll`, `lt`, and `tree` to eza. Raw usage:

```bash
# Basic listing
eza

# Long format
eza -l

# All files (including hidden)
eza -la
eza -a                    # just show, not long format

# Tree view
eza --tree
eza --tree --level=2
eza -T -L 2               # same, shorthand

# With git status per file
eza -l --git

# Icons (needs Nerd Font, JetBrains Mono Nerd Font is in the setup)
eza --icons

# Sort options
eza -l --sort=modified    # newest first (default for -l is --sort=modified)
eza -l --sort=size
eza -l --sort=extension

# Group directories first
eza --group-directories-first

# Show file size in human-readable form (already default for -l)
eza -lh

# Include specific file types
eza -l --only-dirs
eza -l --only-files

# Git-ignore aware (don't show ignored files)
eza -l --git-ignore
```

### The aliases in `.zshrc`

```bash
ls    # eza --icons --group-directories-first
ll    # eza -lah --git --icons
lt    # eza --tree --level=2 --icons
tree  # eza --tree --icons
```

---

## Jumping to Directories (zoxide)

After visiting a directory once, zoxide lets you jump back with a partial name. It ranks by "frecency" (frequency + recency).

```bash
# Jump to a directory
z projects                # any dir matching "projects"
z pr fr                   # narrows by multiple terms (e.g. projects/frontend)
z -                       # previous directory (like cd -)

# Interactive selection with fzf (when multiple matches)
zi projects

# Add a directory to the database without visiting
zoxide add /path/to/dir

# Remove from database
zoxide remove /path/to/dir

# See what zoxide has learned
zoxide query --list
zoxide query --list --score

# Clear database (nuclear option)
rm ~/.local/share/zoxide/db.zo
```

### How it learns

Every `cd` (and zoxide-aware shell integration) registers a visit. The database builds silently in the background. Give it a few days before the jumps feel magical.

### Why `cd` isn't aliased to `z`

`cd` has POSIX-defined behavior that scripts rely on. Aliasing it to `z` breaks any script that uses `cd` with an exact path. Use `z` as its own command; keep `cd` for scripts and exact navigation.

---

## Fuzzy Finding (fzf)

fzf is the general-purpose fuzzy finder. The Brewfile installs it, and `setup.sh` wires up the shell key bindings.

### Default shell bindings (auto-configured by `setup.sh`)

| Keys | What it does |
|---|---|
| `Ctrl+R` | Fuzzy search shell history; replaces the default `Ctrl+R` reverse-search (or wraps Atuin if that's loaded) |
| `Ctrl+T` | Paste fuzzy-selected file paths onto the command line |
| `Alt+C` | `cd` into a fuzzy-selected directory |
| `**<Tab>` | Fuzzy completion trigger (e.g. `vim **<Tab>`) |

> **Mac keyboard note:** `Alt` is the key labeled `Option` (⌥). fzf's docs use the Alt name historically; the physical key to press is Option.

### Inside the fzf picker

| Key | Action |
|---|---|
| Type | Filter |
| `↑` / `↓` | Move selection |
| `Enter` | Select |
| `Esc` | Cancel |
| `Tab` | Multi-select (when `-m` is passed) |
| `Ctrl+/` | Toggle preview window |

### Common standalone uses

```bash
# Pick a file interactively and open it
vim $(fzf)

# Fuzzy-select a git branch to check out
git branch | fzf | xargs git checkout

# Kill a process by fuzzy-picking from `ps`
ps aux | fzf | awk '{print $2}' | xargs kill

# Pick from your history of directories
cd $(zoxide query --list | fzf)

# Search file contents, select a match, open at that line in vim
rg --line-number "" | fzf | awk -F: '{print $1, $2}' | xargs -r vim +
```

### Preview window (already configured in `.zshrc`)

The setup wires bat and eza into fzf's preview:

```bash
# Already in .zshrc
export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"
```

So when you press `Ctrl+T` you see a syntax-highlighted preview of each file; when you press `Alt+C` you see a tree view of each directory.

---

## Shell History (atuin)

Atuin replaces `~/.zsh_history` with a SQLite database. Press `Ctrl+R` for a full-screen search UI.

### Inside the Ctrl+R UI

| Key | Action |
|---|---|
| Type | Filter (fuzzy) |
| `↑` / `↓` | Navigate |
| `Enter` | Execute the selected command |
| `Tab` | Paste to command line without executing |
| `Esc` | Cancel |
| `Ctrl+R` | Cycle through filter modes (global / host / session / directory / workspace) |

### CLI usage

```bash
# Import existing shell history
atuin import auto

# Search from the command line
atuin search "docker"
atuin search --cwd /project         # only commands run in this dir
atuin search --exit 0               # only successful commands
atuin search --after "2026-03"      # time filter
atuin search --host laptop          # only from this machine

# Stats
atuin stats                         # total count, top commands, etc.

# Sync (optional; see manual steps in README)
atuin register -u username -e email@example.com
atuin sync
atuin sync -f                       # force full sync
atuin key                           # show encryption key (save somewhere safe)

# Diagnostics
atuin doctor
atuin info
```

### Config snippets

```toml
# ~/.config/atuin/config.toml

# Search mode
search_mode = "fuzzy"               # prefix, fulltext, fuzzy, skim
filter_mode = "global"              # global, host, session, directory, workspace

# UI
style = "compact"                   # auto, full, compact
inline_height = 40                  # 0 = full screen
show_preview = true
enter_accept = false                # true = run immediately instead of pasting

# Privacy
secrets_filter = true               # filter AWS keys, GitHub tokens, etc. automatically
history_filter = [
  "^password",
  "^secret",
  ".*--password.*",
]
```

### Privacy notes

- `secrets_filter = true` catches common patterns (AWS keys, GitHub tokens, Stripe keys) automatically
- Sync is E2E encrypted; the server can't read your commands
- Without sync, everything stays local in `~/.local/share/atuin/history.db`

---

## Git Diffs (delta)

Delta is a pager for git diffs. Once configured, every `git diff`, `git log -p`, and `git show` gets syntax highlighting and side-by-side view.

### Setup (one-time)

Add to `~/.gitconfig`:

```ini
[core]
    pager = delta

[interactive]
    diffFilter = delta --color-only

[delta]
    navigate = true         # n/N to navigate between files in a diff
    light = false           # set to true if you use a light terminal theme
    line-numbers = true
    side-by-side = true

[merge]
    conflictStyle = zdiff3
```

### Usage

After setup, just use git normally:

```bash
git diff                    # delta-rendered
git log -p                  # delta-rendered
git show HEAD               # delta-rendered
```

### Inside delta (when piping through `less`)

| Key | Action |
|---|---|
| `n` | Next file in diff |
| `N` | Previous file |
| `/` | Search |
| `q` | Quit |

### Standalone

```bash
# Compare two files
delta file1.txt file2.txt

# Pipe any diff into delta
diff file1 file2 | delta
kubectl diff -f deployment.yaml | delta
```

---

## Disk Usage (dust)

```bash
# Basic usage (current directory)
dust

# Specific directory
dust ~/projects

# Depth control
dust -d 3                   # only 3 levels deep

# Number of lines
dust -n 20                  # show top 20 entries

# Reverse (show largest at bottom)
dust -r

# Show file counts instead of size
dust -c

# Include hidden files
dust -H

# Files only (no directories)
dust -f
```

Aliased as `du` in this setup's `.zshrc`.

---

## Resource Monitoring (btop)

Aliased as `top` in `.zshrc`. Launch with `top` or `btop`.

### Navigation

| Key | Action |
|---|---|
| `q` or `Esc` | Quit |
| `?` | Help screen with all keybinds |
| `+` / `-` | Increase / decrease update interval |
| `f` | Filter processes |
| `/` | Search processes |
| `Space` | Select process |
| `t` | Toggle tree view of processes |
| `r` | Reverse sort |
| `e` | Toggle process details expanded |
| `k` | Kill selected process |
| `m` | Sort by memory |
| `p` | Sort by PID |
| `c` | Sort by CPU |

### Views

| Key | Action |
|---|---|
| `1` | Toggle CPU box |
| `2` | Toggle memory box |
| `3` | Toggle network box |
| `4` | Toggle processes box |
| `M` | Toggle themed GPU box (if supported) |

### Configuration

`~/.config/btop/btop.conf`. Edit in-app with `Esc` → Options, or directly with `$EDITOR`.

---

## Quick Docs (tldr)

Simplified man pages with real usage examples. Much more useful than `man` for 90% of "how do I use this tool again" questions.

```bash
tldr tar
tldr git-rebase
tldr fd
tldr docker-compose

# Update the local cache (runs automatically but can be forced)
tldr --update

# List all available pages
tldr --list

# Search
tldr --search "compress"
```

First run downloads a small cache (~3MB) of community-maintained pages.

---

## Composing Tools Together

The real power is combining them. A few patterns worth knowing:

### Fuzzy-find and edit

```bash
# Pick a file with preview, open in editor
vim $(fzf --preview 'bat --color=always {}')

# Pick from ripgrep results, open at the exact line
rg --line-number "" | \
  fzf --delimiter=: --preview 'bat --color=always --highlight-line={2} {1}' | \
  awk -F: '{print "+" $2, $1}' | xargs vim
```

### Fuzzy git branch checkout

```bash
git branch | fzf | xargs git checkout

# With remote branches
git branch -a | grep -v HEAD | fzf | sed 's/.* //' | xargs git checkout
```

### Find and batch-process

```bash
# Find all old log files and pipe to fzf for selection before deleting
fd -e log --changed-before 7d | fzf -m | xargs rm

# Convert a bunch of images
fd -e png -x magick {} -quality 85 {.}.jpg
```

### Search inside a specific file type, with preview

```bash
rg --line-number "TODO" --type rust | \
  fzf --delimiter=: --preview 'bat --color=always --highlight-line={2} {1}'
```

### Tree-style directory preview in zoxide picker

Press `Ctrl+T` on a `zi` command to see tree previews:

```bash
zi    # fzf-based picker with tree preview (already configured)
```

### Pipe any command's output into bat for syntax highlighting

```bash
echo '{"name": "Lakshya"}' | bat -l json
kubectl get pods -o yaml | bat -l yaml
curl -s api.github.com/users/torvalds | bat -l json
```

### Quick project navigation combo

```bash
# Jump to a project and immediately open it in your editor
z projects && cursor .

# Or fuzzy-pick among projects
cd $(fd -t d -d 2 . ~/projects | fzf)
```

---

## Speed Comparison

Rough order-of-magnitude for common tasks. Not rigorous benchmarks; just to show why the switch is worth it.

| Task | Classic | Modern | Typical speedup |
|---|---|---|---|
| Search all .js files for `useState` | `grep -r "useState" --include="*.js"` | `rg "useState" -t js` | 10–100× |
| Find files named `test_*.py` | `find . -name "test_*.py"` | `fd "^test_.*\.py$"` | 3–10× |
| Directory listing with git status | `ls -la && git status` | `eza -la --git` | N/A (feature, not speed) |
| Jump to oft-visited dir | `cd ~/projects/company/frontend/src/components` | `z components` | 10× less typing |

The bigger win than raw speed is **better defaults**: ripgrep respects `.gitignore`, fd has intuitive syntax, bat shows line numbers by default. You spend less time configuring and more time doing.

---

## Configuration Files Summary

Most tools in this cheat sheet respect these locations:

| Tool | Config location |
|---|---|
| ripgrep | `~/.ripgreprc` (if `RIPGREP_CONFIG_PATH` is set) |
| bat | `$(bat --config-file)` (usually `~/.config/bat/config`) |
| atuin | `~/.config/atuin/config.toml` |
| btop | `~/.config/btop/btop.conf` |
| delta | Lives in `~/.gitconfig` under `[delta]` section |
| fzf | Environment variables in `~/.zshrc` (see above) |
| eza | None; configure via aliases in `.zshrc` |
| zoxide | None; controlled by env vars; database at `~/.local/share/zoxide/db.zo` |
| fd | None; use shell aliases if you want different defaults |

All configs in this repo are either in the root (`.zshrc`, `starship.toml`) or commented into `.zshrc` itself for these tools.
