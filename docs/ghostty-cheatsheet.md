# Ghostty Cheat Sheet & Best Practices

A reference for Ghostty on macOS (2026). Covers default keybindings, config syntax, common actions, and the gotchas that trip people up.

Official docs: <https://ghostty.org/docs>

---

## Table of Contents

- [Default Keybindings (macOS)](#default-keybindings-macos)
- [Config File Basics](#config-file-basics)
- [Keybind Syntax](#keybind-syntax)
- [Quick Terminal (Quake Mode)](#quick-terminal-quake-mode)
- [Useful Config Options](#useful-config-options)
- [Action Reference](#action-reference)
- [Themes & Fonts](#themes--fonts)
- [Shell Integration](#shell-integration)
- [SSH & Terminfo Gotchas](#ssh--terminfo-gotchas)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

---

## Default Keybindings (macOS)

These ship with Ghostty and don't require config. All use the `Cmd` modifier to match native macOS conventions.

### Windows & Tabs

| Shortcut | Action |
|---|---|
| `Cmd+N` | New window |
| `Cmd+T` | New tab |
| `Cmd+W` | Close current tab / split / window |
| `Cmd+1` ... `Cmd+9` | Jump to tab by index |
| `Cmd+Shift+]` | Next tab |
| `Cmd+Shift+[` | Previous tab |
| `Cmd+Enter` | Toggle native fullscreen |

### Splits (Panes)

| Shortcut | Action |
|---|---|
| `Cmd+D` | New split right *(requires config; see below)* |
| `Cmd+Shift+D` | New split down *(requires config; see below)* |
| `Cmd+Alt+←/→/↑/↓` | Navigate between splits *(requires config)* |
| `Cmd+Shift+Enter` | Toggle zoom on current split (tmux-style) |
| `Cmd+Shift+E` | Equalize splits |

Note: Split *creation* keybindings aren't default; they're in your `ghostty-config`. Navigation between existing splits is fully default on macOS. (`Alt` in shortcuts above = the key labeled Option `⌥`.)

### Clipboard

| Shortcut | Action |
|---|---|
| `Cmd+C` | Copy |
| `Cmd+V` | Paste |
| `Cmd+Shift+V` | Paste without formatting |

### Font & Zoom

| Shortcut | Action |
|---|---|
| `Cmd++` | Increase font size |
| `Cmd+-` | Decrease font size |
| `Cmd+0` | Reset font size |

### Config & Inspection

| Shortcut | Action |
|---|---|
| `Cmd+,` | Open config file in default editor |
| `Cmd+Shift+,` | Reload config |
| `Cmd+Shift+P` | Command palette (experimental in some builds) |

### Quick Terminal (if configured)

| Shortcut | Action |
|---|---|
| `Ctrl+\`` (backtick) | Toggle Quake-style dropdown terminal |

---

## Config File Basics

**Location:** `~/.config/ghostty/config`

**Syntax:** simple `key = value`, no TOML/YAML:

```
# Comments use #
# Blank lines ignored
# Keys are case-sensitive and always lowercase

font-family = JetBrainsMono Nerd Font
font-size = 14
theme = catppuccin-mocha

# Empty value resets to default
font-family =
```

**Multiple values** (only for options that accept lists like `keybind` or `font-feature`) are specified by repeating the key:

```
keybind = cmd+d=new_split:right
keybind = cmd+shift+d=new_split:down

font-feature = -calt
font-feature = -liga
```

**Reload after editing:** `Cmd+Shift+,` or just restart Ghostty. Some options only apply to new windows.

---

## Keybind Syntax

General form:

```
keybind = [prefix:]modifiers+key=action[:argument]
```

### Prefixes

| Prefix | Meaning |
|---|---|
| (none) | Per-surface keybind, only fires when that terminal is focused |
| `global:` | System-wide, works even when Ghostty isn't focused *(macOS only; requires Accessibility permission)* |
| `all:` | Fires in every Ghostty surface |
| `unconsumed:` | Don't swallow the keypress; also send it to the running program |

### Modifiers

`cmd`, `ctrl`, `alt` (also `option`), `shift`, `super` (Linux).

### Examples

```
# Open a split to the right when you press Cmd+D
keybind = cmd+d=new_split:right

# System-wide dropdown (Quake-style)
keybind = global:ctrl+grave_accent=toggle_quick_terminal

# Reload config
keybind = cmd+shift+comma=reload_config

# Clear the default behavior
keybind = cmd+d=
```

---

## Quick Terminal (Quake Mode)

A terminal that drops down from the top of the screen on a global hotkey, regardless of which app is focused. Very useful for quick one-offs without switching apps.

**To enable**, add these to your config:

```
quick-terminal-position = top
quick-terminal-screen = mouse
quick-terminal-autohide = true
keybind = global:ctrl+grave_accent=toggle_quick_terminal
```

**First launch** will prompt for Accessibility permission in System Settings > Privacy & Security > Accessibility. This is required for `global:` keybinds to work. Without it, the hotkey silently does nothing.

**Position options:** `top`, `bottom`, `left`, `right`, `center`.

---

## Useful Config Options

The options that actually matter day-to-day. Full reference: <https://ghostty.org/docs/config/reference>.

### Appearance

```
theme = catppuccin-mocha
# Or auto-switch with system appearance:
theme = light:Catppuccin Latte,dark:Catppuccin Mocha

font-family = JetBrainsMono Nerd Font
font-size = 14
font-thicken = false            # makes fonts bold; can look muddy on HiDPI

background-opacity = 0.97
background-blur-radius = 20     # frosted-glass effect behind the window

macos-titlebar-style = tabs     # tabs | transparent | native | hidden
window-padding-x = 10
window-padding-y = 10
```

### Behavior

```
window-save-state = always      # restore layout after restart
copy-on-select = clipboard      # Linux-style auto-copy on text selection
mouse-hide-while-typing = true  # hides cursor while typing
clipboard-paste-protection = true   # default, confirms suspicious pastes
```

### Performance / Buffer

```
scrollback-limit = 25000000     # 25M lines, generous for AI coding agents
```

### Auto-Update

```
auto-update-channel = stable    # or "tip" for prerelease builds
```

### SSH Compatibility

```
term = xterm-256color           # fall back to a widely-recognized TERM
```

### List All Available Options

```bash
# Print the full default config with inline docs
ghostty +show-config --default --docs

# Just list available themes
ghostty +list-themes

# Just list available fonts on this system
ghostty +list-fonts

# See every default keybinding
ghostty +list-keybinds --default
```

---

## Action Reference

Actions are what you bind keys to. The common ones on macOS:

### Surfaces (windows/tabs/splits)

| Action | Description |
|---|---|
| `new_window` | Open a new window |
| `new_tab` | Open a new tab |
| `close_surface` | Close current tab, split, or window |
| `new_split:right`, `new_split:down`, `new_split:left`, `new_split:up` | Split in the given direction |
| `goto_split:right/left/top/bottom` | Move focus to adjacent split |
| `equalize_splits` | Reset splits to equal sizes |
| `toggle_split_zoom` | Maximize current split within the tab (tmux-style) |
| `goto_tab:N` | Jump to tab N |
| `previous_tab` / `next_tab` | Cycle tabs |
| `toggle_fullscreen` | Native macOS fullscreen |

### Config & Meta

| Action | Description |
|---|---|
| `reload_config` | Re-read config without restarting |
| `open_config` | Open config in default editor |
| `toggle_quick_terminal` | Show/hide Quake-style dropdown |

### Font

| Action | Description |
|---|---|
| `increase_font_size:N` | Bump font up by N points |
| `decrease_font_size:N` | Bump font down by N points |
| `reset_font_size` | Back to configured default |

### Scrolling & Buffer

| Action | Description |
|---|---|
| `scroll_to_top` / `scroll_to_bottom` | Jump to start/end of buffer |
| `scroll_page_up` / `scroll_page_down` | Page-by-page scrolling |
| `clear_screen` | Clear visible screen but keep scrollback |
| `write_scrollback_file:open` | Dump scrollback to a temp file and open it |

Full list: <https://ghostty.org/docs/config/keybind/reference>

---

## Themes & Fonts

### Browse & Preview Themes

```bash
# List all built-in themes
ghostty +list-themes

# Preview a theme immediately without editing config
ghostty --theme=tokyo-night
```

### Popular Choices (2026)

| Theme | Vibe |
|---|---|
| `catppuccin-mocha` | Dark, soft pastel, current community favorite |
| `catppuccin-latte` | Light variant of above |
| `tokyo-night` | Dark, neon city, pairs well with blur |
| `rose-pine` | Muted, organic palette |
| `gruvbox-material` | Retro but functional high-contrast |
| `dracula` | Classic high-contrast dark |

### Fonts

**Must be a Nerd Font** if your prompt uses glyphs (Starship, eza icons). Install via Homebrew:

```bash
brew install --cask font-jetbrains-mono-nerd-font
brew install --cask font-fira-code-nerd-font
brew install --cask font-meslo-lg-nerd-font
```

Then in config:

```
font-family = JetBrainsMono Nerd Font   # exact name with spaces
```

**Gotcha:** common mistake is using `JetBrainsMonoNerdFont` (no spaces). That name doesn't match what Homebrew installs and silently falls back to default monospace.

---

## Shell Integration

Ghostty auto-detects your shell and injects integration features: semantic prompt markers, working-directory tracking, command status indicators, and more.

```
shell-integration = detect      # default, usually leave this alone
```

Supported shells: zsh, bash, fish, elvish.

**If you want to disable it** (rare; sometimes conflicts with custom prompts):

```
shell-integration = none
```

**Manual shell integration** (e.g. for a non-standard shell location) is documented at <https://ghostty.org/docs/help/terminfo>.

---

## SSH & Terminfo Gotchas

Ghostty's default `TERM` is `xterm-ghostty`, which older remote systems don't have in their terminfo database. Symptoms when SSHing:

```
Error opening terminal: xterm-ghostty
```

Or vim/less rendering weirdly. **Two fixes:**

### Fix 1 (recommended): fall back to `xterm-256color` over SSH

In `~/.config/ghostty/config`:

```
term = xterm-256color
```

Safe, universal, what almost everyone does.

### Fix 2: install Ghostty's terminfo on the remote

Preserves full Ghostty feature support on that host:

```bash
infocmp -x xterm-ghostty | ssh user@remote -- tic -x -
```

Do this once per remote you care about.

---

## Best Practices

### Commit your config to dotfiles

`~/.config/ghostty/config` is plain text. Version it. In this repo it's at `ghostty-config` in the root and symlinked into place by `setup.sh`.

### Keep the config minimal

Ghostty's defaults are carefully chosen. Only override what you need. Every option you set is a future compat burden; a terse config ages better than an exhaustive one.

### Use `ghostty +show-config --default --docs` before adding an option

Confirms the option exists, shows its default, and gives you inline docs without a web round-trip.

### Don't override macOS defaults unless needed

`Cmd+T` for new tab, `Cmd+W` for close, `Cmd+1..9` for tab switching are already there. Rebinding them breaks muscle memory from other Mac apps.

### Add the SSH fallback before you need it

`term = xterm-256color` costs nothing in local use and saves a confusing afternoon the first time you SSH somewhere.

### Test keybinds with `+list-keybinds`

When in doubt about whether something is already bound:

```bash
ghostty +list-keybinds --default
ghostty +list-keybinds             # includes your overrides
```

### Use `global:` keybinds sparingly

Each one needs Accessibility permission and can conflict with other apps. One for Quick Terminal is plenty; don't binda dozen of them.

---

## Troubleshooting

**Config changes don't take effect**

- Did you reload? `Cmd+Shift+,`
- Some options only apply to new windows (e.g. `window-padding-*`). Open a new window to test.
- Check the config was actually parsed: `ghostty +show-config` prints the effective config.

**Font shows as generic monospace, icons are squares**

- Font name mismatch. The cask name (`font-jetbrains-mono-nerd-font`) is different from the font's actual name (`JetBrainsMono Nerd Font` with spaces). Use `ghostty +list-fonts | grep -i jetbrains` to see the exact name.

**`global:` keybind doesn't fire**

- macOS Accessibility permission not granted. Go to System Settings > Privacy & Security > Accessibility and add Ghostty.
- Restart Ghostty after granting.

**SSH sessions look broken (vim, less, top)**

- Set `term = xterm-256color` in config (see SSH section above).

**"command not found" on tools that work in other terminals**

- Usually a `$PATH` issue, not a Ghostty issue. Ghostty runs your login shell fresh; if the tool's path is exported in `.bashrc` but not `.zshrc` (or vice versa), it won't be found. Check your shell config.

**Quick Terminal doesn't toggle**

- Verify the keybind: `ghostty +list-keybinds | grep quick_terminal`.
- Confirm Accessibility permission is granted.
- Try a different hotkey. `Ctrl+\`` can conflict with some input methods or other apps.

**High CPU or memory use**

- Check `scrollback-limit`. 25M lines is fine for most; 100M+ can be memory-heavy with lots of windows.
- Try `ghostty +show-config` to confirm no runaway shader config is active.

**Reset to defaults**

```bash
# Back up current config
mv ~/.config/ghostty/config ~/.config/ghostty/config.bak

# Ghostty now runs with pure defaults
# Re-add overrides one at a time to find which one caused the issue
```
