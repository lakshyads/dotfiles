# Lazygit Cheat Sheet

A reference for lazygit, the keyboard-driven TUI for git. Covers the panels, default keybindings, common workflows, and the features that take lazygit from "nicer git" to "faster than the CLI."

Launch with `lazygit` or the alias `lg` (configured in this setup's `.zshrc`).

Official docs: <https://github.com/jesseduffield/lazygit>

---

## Table of Contents

- [Mental Model: The Five Panels](#mental-model-the-five-panels)
- [Universal Keybindings](#universal-keybindings)
- [Files Panel](#files-panel)
- [Local Branches Panel](#local-branches-panel)
- [Commits Panel](#commits-panel)
- [Stash Panel](#stash-panel)
- [Status Panel](#status-panel)
- [Line-Staging View](#line-staging-view)
- [Interactive Rebase](#interactive-rebase)
- [Common Workflows](#common-workflows)
- [Customization](#customization)
- [Tips & Gotchas](#tips--gotchas)

---

## Mental Model: The Five Panels

Lazygit's interface is divided into numbered panels. Switch between them with number keys or `Tab`:

| Key | Panel | What lives here |
|---|---|---|
| `1` | Status | Repo info, settings, current branch summary |
| `2` | Files | Working tree changes (staged and unstaged) |
| `3` | Local Branches | Your branches (also remotes via tab within) |
| `4` | Commits | Commit history with reflog/tags as tabs |
| `5` | Stash | All your stashes |

Each panel has its own keybindings depending on what's selected. Press `?` anytime to see the keybindings for the current panel.

---

## Universal Keybindings

These work in any panel:

| Key | Action |
|---|---|
| `?` | Show help for current panel |
| `q` | Quit |
| `Esc` | Close menu / cancel prompt |
| `Tab` | Next panel |
| `Shift+Tab` | Previous panel |
| `1`-`5` | Jump to panel by number |
| `Ctrl+r` | Reload (refresh state from disk) |
| `m` | Menu of pending actions (rebase/merge options during conflicts) |
| `x` | Open command log (see what git commands lazygit ran) |
| `:` | Execute a custom shell command |
| `P` | Push |
| `p` | Pull |
| `R` | Refresh |
| `+` / `_` | Expand / collapse focused view |
| `@` | Open custom command shell |
| `/` | Filter/search within a panel |

Arrow keys or `j`/`k` (vim-style) move up/down within a panel.

---

## Files Panel

The one you'll use most. Shows unstaged and staged changes.

### Staging

| Key | Action |
|---|---|
| `space` | Stage / unstage file |
| `a` | Stage / unstage ALL files |
| `Enter` | Focus the staging view (for line-by-line staging) |
| `d` | Discard changes (menu with options) |
| `D` | Nuke all changes in working tree (menu) |
| `M` | Resolve merge conflict using merge tool |
| `e` | Edit file in `$EDITOR` |
| `o` | Open file in default app |
| `i` | Add file to `.gitignore` |
| `I` | Add file to `.git/info/exclude` (local-only ignore) |
| `s` | Stash (menu with options) |
| `S` | View stash options |

### Committing

| Key | Action |
|---|---|
| `c` | Commit |
| `C` | Commit using git editor (for multi-line messages) |
| `w` | Commit as WIP |
| `A` | Amend last commit (uses staged changes, keeps message) |
| `Shift+A` | Amend last commit message only |
| `Ctrl+o` | Copy file name to clipboard |

### View Options

| Key | Action |
|---|---|
| `` ` `` | Toggle file view: flat ↔ tree layout |
| `b` | Open a filter popup (useful in large repos) |

---

## Local Branches Panel

### Navigation

| Key | Action |
|---|---|
| `Tab` (within panel) | Cycle: local / remotes / tags |
| `space` | Check out selected branch |
| `o` | Create pull request in browser (requires `gh` installed + authed) |
| `O` | Copy PR URL to clipboard |

### Branch Operations

| Key | Action |
|---|---|
| `n` | New branch (from selected) |
| `N` | New branch from current position |
| `d` | Delete branch (menu: local, remote, or both) |
| `r` | Rename branch |
| `R` | Rebase current branch onto selected |
| `M` | Merge selected branch into current |
| `f` | Fast-forward branch (without checkout) |
| `u` | Set upstream |
| `g` | View reset options (soft/mixed/hard) |
| `T` | Create tag |
| `w` | Create worktree from branch |
| `Enter` | Show commits for this branch |

### Remotes Tab

When on a remote branch:

| Key | Action |
|---|---|
| `space` | Check out local copy |
| `M` | Merge into current |
| `R` | Rebase current onto this |
| `d` | Delete remote branch |

---

## Commits Panel

The most powerful panel. Handles rebasing, cherry-picking, and history rewriting.

### Navigation & Inspection

| Key | Action |
|---|---|
| `Enter` | View commit files (drill into what changed) |
| `space` | Check out commit (detached HEAD) |
| `y` | Copy commit attribute menu (hash, URL, diff, message, author) |
| `Ctrl+j` / `Ctrl+k` | Move commit down / up in history |

### Editing Commits

Each of these starts an interactive rebase automatically:

| Key | Action |
|---|---|
| `s` | Squash commit into the one below |
| `f` | Fixup (squash but discard message) |
| `r` | Reword commit message |
| `R` | Reword using git editor |
| `e` | Edit commit (stop at this commit during rebase) |
| `d` | Drop commit (delete) |
| `p` | Pick commit (during interactive rebase) |

### Amending & Fixups

| Key | Action |
|---|---|
| `A` | Amend selected commit with current staged changes |
| `Shift+F` | Create fixup commit for selected commit (auto-targets it) |
| `Ctrl+f` | Find the commit your current changes build upon (for `--fixup`) |

### Cherry-Picking

| Key | Action |
|---|---|
| `c` | Mark commit as copied |
| `Shift+C` | Mark commit range as copied |
| `v` | Paste (cherry-pick) copied commits |
| `Esc` | Cancel copied-commits selection |

### Reverting & Resetting

| Key | Action |
|---|---|
| `t` | Revert commit (creates inverse commit) |
| `g` | Reset to this commit (menu: soft/mixed/hard) |

### Interactive Rebase Entry Points

| Key | Action |
|---|---|
| `i` | Start interactive rebase from this commit |
| `Ctrl+r` | Revert merge commit (pick which parent to keep) |

Once a rebase is running, `m` brings up the rebase options menu (continue/abort/skip).

---

## Stash Panel

| Key | Action |
|---|---|
| `space` | Apply stash |
| `g` | Pop stash (apply + remove) |
| `d` | Drop stash |
| `n` | New branch from stash |
| `r` | Rename stash |
| `Enter` | View stash contents |

---

## Status Panel

| Key | Action |
|---|---|
| `e` | Edit lazygit config |
| `o` | Open lazygit config location |
| `u` | Check for lazygit updates |
| `Enter` | Switch repos (from recent list) |

---

## Line-Staging View

Press `Enter` on a file in the Files panel to open this. It's the lazygit equivalent of `git add -p` but dramatically more ergonomic.

| Key | Action |
|---|---|
| `space` | Stage / unstage the selected line |
| `a` | Stage / unstage the whole hunk |
| `v` | Start selection mode (highlight multiple lines) |
| `Ctrl+o` | Copy selected lines to clipboard |
| `Esc` / `Return` | Back to files panel |
| `d` | Discard the selected line/hunk |
| `e` | Edit in external editor |
| `/` | Search within the diff |

### Selection mode (after pressing `v`)

- Arrow keys extend the selection
- `space` stages the selected lines
- `d` discards them
- `Esc` cancels selection

This is lazygit's single biggest quality-of-life win over the CLI. Splitting a messy working directory into clean commits becomes trivial.

---

## Interactive Rebase

Lazygit does interactive rebase via direct actions rather than opening an editor. Workflow:

1. In the Commits panel, select the commit you want to modify
2. Press the action key (`s` squash, `r` reword, `e` edit, `d` drop, etc.)
3. Lazygit starts the rebase; if an `edit` action stops it, you make changes and press `m` → `continue`
4. Conflicts pause at each affected commit; resolve via the Files panel and press `m` → `continue`

### Moving commits

- `Ctrl+j` / `Ctrl+k`: move the selected commit down/up
- Lazygit automatically rebases to make the move happen

### Squashing a range

- Mark top commit with `Shift+V` (enter range-select mode)
- Move down to include more commits
- Press `s` to squash them all

### Dropping a range

- Same as squashing: `Shift+V`, extend selection, then `d`

### When things go wrong

- `m` opens the rebase options menu: **continue**, **abort**, **skip**
- `Ctrl+r` hard-refreshes lazygit's view

---

## Common Workflows

### Quick commit with line-staging

1. `2`: go to Files panel
2. `Enter` on the file you want to stage
3. `v` to start selection, arrow keys to highlight desired lines, `space` to stage
4. `Esc` back to Files
5. `c` to commit, type message, `Enter`

### Rename the last commit

1. `4`: go to Commits panel
2. Top commit is already selected
3. `r`: prompt opens with current message pre-filled
4. Edit, `Enter`

### Fix a typo in an older commit (autofixup)

1. Stage the fix in the Files panel
2. `4`: go to Commits panel
3. `Ctrl+f`: lazygit finds the commit your changes build upon
4. `Shift+F`: creates a `fixup!` commit targeting it
5. Start interactive rebase (`i`) on that commit's parent, then `m` → continue, and the fixup is auto-squashed

### Cherry-pick a range

1. `4`: Commits panel
2. Navigate to the first commit you want to pick
3. `c`: mark as copied
4. Shift+C to mark a range, or `c` on additional commits
5. Switch to target branch (`3`, `space`)
6. Back in Commits, `v` to paste/cherry-pick

### Stash, switch branches, restore

1. In Files, `s`: stash menu → pick "stash all"
2. `3`: branches → `space` on target branch
3. `5`: Stash panel → `g` on your stash to pop it

### Resolve a merge conflict

1. Start the merge (`M` on a branch in the Branches panel)
2. If conflicts: you'll see them in the Files panel, highlighted
3. `Enter` on a conflicted file → lazygit opens a three-way view
4. `space` on the "ours"/"theirs"/"both" lines to pick
5. Once all conflicts resolved: `m` → continue

### Amend a just-committed change

1. Fix the code, stage in Files (`space`)
2. `A`: amend (uses current staged changes, keeps message)

Or: `a` (stage all), then `A`.

### Push to a new remote branch

1. `P` to push. If no upstream set, lazygit prompts you to set it.
2. If prompt wants to `--force`, press `Esc` first to decide. Only use force-push if you're sure (lazygit uses `--force-with-lease` by default, which is safer).

---

## Customization

### Config location

```bash
~/Library/Application Support/lazygit/config.yml      # macOS
~/.config/lazygit/config.yml                          # Linux (XDG)
```

Or open it directly from within lazygit: press `e` on the Status panel.

### Useful config snippets

```yaml
# ~/Library/Application Support/lazygit/config.yml

gui:
  showFileTree: true                    # tree view for files by default
  showIcons: true                       # needs a Nerd Font
  nerdFontsVersion: "3"                 # matches JetBrainsMono Nerd Font in our setup
  theme:
    activeBorderColor: [green, bold]
    inactiveBorderColor: [white]
    selectedLineBgColor: [blue]

git:
  paging:
    colorArg: always
    pager: delta --dark --paging=never   # git-delta integration (already in Brewfile)
  autoFetch: true
  commit:
    signOff: false

os:
  editPreset: "vscode"                   # or "cursor", "nvim", etc.

keybinding:
  universal:
    quit: 'q'
    return: '<esc>'
```

### Delta integration (already set up in this repo)

Since `git-delta` is in the Brewfile, you can wire it in to get syntax-highlighted diffs inside lazygit:

```yaml
git:
  paging:
    colorArg: always
    pager: delta --paging=never
```

### Custom commands

You can bind keys to shell commands that lazygit runs against the current context. Example: open selected commit on GitHub with `Ctrl+B`:

```yaml
customCommands:
  - key: '<c-b>'
    context: 'commits'
    command: 'gh browse {{.SelectedLocalCommit.Hash}}'
    description: 'Open commit in GitHub'
```

See full docs: <https://github.com/jesseduffield/lazygit/blob/master/docs/Custom_Command_Keybindings.md>

---

## Tips & Gotchas

### The command log is your friend

Press `x` to see every git command lazygit ran. Great for learning what git invocation maps to which TUI action, and debugging when something unexpected happens.

### Lazygit uses `--force-with-lease`, not `--force`

When you press `P` to push after rewriting history, lazygit uses the safer variant. If it still refuses (remote has changes you don't), it'll tell you.

### Staging individual lines requires `Enter` first

Pressing `space` on a file in the Files panel stages the whole file. To stage lines, press `Enter` first to enter the line-staging view.

### Tree vs flat file layout

Toggle with `` ` `` (backtick) in the Files panel. Tree view groups by directory; flat shows full paths. Tree is usually better for small repos, flat for large ones where you want to see paths at a glance.

### PR info from GitHub

If you've run `gh auth login`, lazygit shows a GitHub icon next to branches with open PRs. Press `Shift+G` on such a branch to open the PR in your browser. No lazygit-specific config needed.

### Multiple repos

Press `Enter` on the Status panel to switch between recent repos without leaving lazygit. Great for quickly bouncing between a backend and frontend repo during development.

### Don't fear rebase conflicts

Lazygit handles interactive rebase conflicts much more smoothly than the CLI. When a conflict pauses the rebase, you're dropped into the Files panel with the conflict highlighted. Resolve → `m` → continue. Repeat until done.

### Filter panels with `/`

Every panel (except Status) supports `/` for instant filter. Handy when you have 50 branches or 20 uncommitted files.

### Force-quit if stuck

If a rebase or merge leaves lazygit in a weird state, press `m` → `abort`. If even that fails, `q` to quit, then from a regular terminal: `git rebase --abort` or `git merge --abort`.
