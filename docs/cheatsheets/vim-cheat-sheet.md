---
tag:
  - type/cheatsheet
  - topic/vim
  - topic/editor
related:
  - "[[modern-cli-cheatsheet]]"
---
# Vim Cheat Sheet (80/20)

## Modes

| Mode | Enter | Purpose |
|------|-------|---------|
| Normal | `Esc` | Navigate & manipulate text |
| Insert | `i`, `a`, `o` | Type text |
| Visual | `v`, `V`, `Ctrl+v` | Select text |
| Command | `:` | Run commands like save/quit |

---

# Movement

## Character

| Command | Action |
|----------|--------|
| `h` | Left |
| `j` | Down |
| `k` | Up |
| `l` | Right |

## Word

| Command | Action |
|----------|--------|
| `w` | Next word start |
| `b` | Previous word start |
| `e` | End of current/next word |

Example:

```text
hello amazing world
^
```

| Keys | Cursor moves to |
|------|-----------------|
| `w` | `amazing` |
| `w` | `world` |
| `b` | `amazing` |
| `e` | End of `amazing` |

---

## Line

| Command | Action |
|----------|--------|
| `0` | Beginning of line |
| `^` | First non-whitespace character |
| `$` | End of line |

---

## File

| Command | Action |
|----------|--------|
| `gg` | Top of file |
| `G` | Bottom of file |
| `25G` | Go to line 25 |

---

## Matching Brackets

| Command | Action |
|----------|--------|
| `%` | Jump between matching `()`, `{}`, `[]` |

---

## Find Characters

| Command | Action |
|----------|--------|
| `fx` | Jump to next `x` |
| `tx` | Jump before next `x` |
| `Fx` | Search backward for `x` |
| `Tx` | Search backward before `x` |

Example:

```text
const myVariable = foo();
^
```

- `f=` → cursor on `=`
- `t=` → cursor before `=`

---

# Editing

## Insert

| Command | Action |
|----------|--------|
| `i` | Insert before cursor |
| `a` | Insert after cursor |
| `o` | Open new line below |

---

## Delete

| Command | Action |
|----------|--------|
| `x` | Delete character |
| `dd` | Delete current line |

---

## Copy & Paste

| Command | Action |
|----------|--------|
| `yy` | Copy current line |
| `p` | Paste after cursor |

---

## Undo / Redo

| Command | Action |
|----------|--------|
| `u` | Undo |
| `Ctrl+r` | Redo |

---

# Operators

General form:

```
operator + motion
```

Examples:

| Command | Meaning |
|----------|---------|
| `dw` | Delete word |
| `diw` | Delete current word |
| `ciw` | Change current word |
| `dap` | Delete paragraph |
| `cip` | Change paragraph |
| `d$` | Delete to end of line |
| `c$` | Change to end of line |

---

## Examples

### `dw`

Deletes from the cursor to the end of the word.

### `diw`

Deletes the entire word regardless of cursor position.

Before

```text
hello amazing world
      ^
```

After

```text
hello  world
```

---

### `ciw`

Deletes the word and immediately enters Insert mode.

Before

```js
const age = 25;
```

Cursor anywhere on `age`

```
ciw
name
<Esc>
```

Result

```js
const name = 25;
```

---

### `d$`

Deletes from the cursor to the end of the line.

---

### `c$`

Deletes to the end of the line and enters Insert mode.

---

# Search

| Command | Action |
|----------|--------|
| `/text` | Search forward |
| `n` | Next match |
| `*` | Next occurrence of current word |
| `#` | Previous occurrence of current word |

Example:

```
/function
```

Press `Enter`, then `n` for the next match.

---

# Visual Mode

## Character Selection

| Command | Action |
|----------|--------|
| `v` | Select characters |

---

## Line Selection

| Command | Action |
|----------|--------|
| `V` | Select whole lines |

---

## Block Selection

| Command | Action |
|----------|--------|
| `Ctrl+v` | Rectangular selection |

Useful for editing multiple lines simultaneously.

---

# Most Useful Everyday Commands

| Command | Purpose |
|----------|---------|
| `w` | Next word |
| `b` | Previous word |
| `$` | End of line |
| `^` | First code on line |
| `gg` | Top of file |
| `G` | Bottom of file |
| `%` | Matching bracket |
| `i` | Insert |
| `a` | Append |
| `o` | New line |
| `x` | Delete character |
| `dd` | Delete line |
| `yy` | Copy line |
| `p` | Paste |
| `u` | Undo |
| `Ctrl+r` | Redo |
| `dw` | Delete word |
| `diw` | Delete current word |
| `ciw` | Replace current word |
| `d$` | Delete to end of line |
| `c$` | Replace to end of line |
| `/` | Search |
| `n` | Next search result |
| `*` | Next occurrence of current word |
| `#` | Previous occurrence of current word |
| `v` | Character selection |
| `V` | Line selection |
| `Ctrl+v` | Block selection |

---

# The Vim Formula

Almost every Vim command follows this pattern:

```
[count] + operator + motion
```

Examples:

| Command | Meaning |
|----------|---------|
| `3w` | Move forward 3 words |
| `5j` | Move down 5 lines |
| `2dd` | Delete 2 lines |
| `d3w` | Delete 3 words |
| `c2w` | Change 2 words |
| `y$` | Copy to end of line |

Once you understand this pattern, you can derive hundreds of Vim commands without memorizing them individually.

---
