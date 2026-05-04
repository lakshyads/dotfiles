# Claude Code Rules for this Dotfiles Repo

## 1. Always search this repo first

Before answering any question about this Mac dev setup, shell tools, CLI tools, configs, or anything that could be documented here — **read the repo first**.

### Where to look (in order)

| Question type | Search here first |
|---|---|
| What is installed / how | `docs/inventory.md` |
| How-to / CLI reference | `docs/` cheat sheets (see index below) |
| Bootstrap / wiring | `setup.sh`, `verify.sh`, `Brewfile`, `.tool-versions` |
| Live config / "what is set?" | Root dotfiles: `.zshrc`, `starship.toml`, `ghostty-config` |
| Setup walkthrough / daily commands | `README.md` |

### docs/ index

See [`README.md` — Cheat Sheets & References](README.md#cheat-sheets--references) for the full annotated index. Key lookup:

| Topic | File |
|-------|------|
| Installed software (what, how installed) | `docs/inventory.md` |
| Homebrew / Brewfile | `docs/homebrew-cheatsheet.md` |
| Language runtimes | `docs/asdf-cheatsheet.md` |
| Terminal keybindings / config | `docs/ghostty-cheatsheet.md` |
| Git workflows | `docs/git-cheatsheet.md` |
| Git TUI | `docs/lazygit-cheatsheet.md` |
| Modern CLI tools | `docs/modern-cli-cheatsheet.md` |
| Claude Code CLI | `docs/claude-code-cheatsheet.md` |
| Cursor IDE | `docs/cursor-cli-cheatsheet.md` |

### How to search

Use `rg` (ripgrep) to find relevant content fast before doing a full file read:

```
rg "<keyword>" /Users/lakshyadevsingh/dotfiles/docs/ -l
rg "<keyword>" <matched-file> -n
```

---

## 2. Sources of truth — one file owns each type of data

Never duplicate these. Every other place must link, not repeat.

| Data | Authoritative file | What goes here |
|------|--------------------|----------------|
| Installed packages (formulae + casks) | `Brewfile` | Every `brew install` and `brew install --cask` |
| Language runtime versions | `.tool-versions` | Version numbers only — never written in docs |
| Zsh plugin list | `.zsh_plugins.txt` | Plugin names only — never written in docs |
| Human-readable inventory | `docs/inventory.md` | What's installed, how, one row per item |
| Detailed command references | `docs/*-cheatsheet.md` | Full usage, flags, examples, gotchas |
| Orientation + links | `README.md` | Overview only — links to cheatsheets, no duplicated content |

---

## 3. No duplicate content across docs

**One source, everywhere else links.**

- If a table, code block, or list already exists in one doc, all other docs must link to it — never copy it.
- `README.md` is orientation only: it describes categories and links out. It does not contain tool lists, keybinding tables, command blocks, or version numbers.
- Version numbers appear only in `.tool-versions`. Docs name the language (e.g. "Node.js") but never the version.
- Plugin names appear only in `.zsh_plugins.txt`. Docs say "see `.zsh_plugins.txt`" rather than listing plugins.
- When adding content from the web: place it in the single most relevant `docs/*-cheatsheet.md`. Do not add it to README as well.

---

## 4. Adding a new tool, app, or runtime — full checklist

Work through every applicable item. Skipping any item leaves the repo inconsistent.

### Adding a Homebrew formula

- [ ] Add to `Brewfile` under the correct section comment
- [ ] Add a row to the appropriate CLI tools section in `docs/inventory.md` (include "Installed via: `brew install`")
- [ ] Add to the matching category block in `setup.sh` with a `want "..."` + `formula ...` line
- [ ] Add to the CLI tools loop in `verify.sh` if it provides a binary

### Adding a Homebrew cask (GUI app)

- [ ] Add to `Brewfile` under the correct section comment
- [ ] Add a row to the GUI Applications table in `docs/inventory.md` (include "Installed via: `brew install --cask`")
- [ ] Add to the matching category block in `setup.sh` with a `want "..."` + `cask_pkg ...` line
- [ ] Add to the `APPS` array in `verify.sh`
- [ ] If the app writes back to a config file, symlink that file into the dotfiles repo so changes persist (see `linearmouse.json` pattern in `setup.sh`)

### Adding a language runtime (asdf)

- [ ] Add to `.tool-versions` (version number goes here and nowhere else)
- [ ] Add a row to the Language Runtimes table in `docs/inventory.md` (language name and `.tool-versions` key only — no version number)
- [ ] Add `asdf plugin add <lang>` to the asdf section in `setup.sh`
- [ ] Add the language to the runtime loop in `verify.sh`

### Adding a Zsh plugin

- [ ] Add to `.zsh_plugins.txt` (plugin entry goes here and nowhere else)
- [ ] Add a row to the Zsh plugins table in `docs/inventory.md`
- [ ] Add a `check_contains` line for the plugin in `verify.sh`

### Removing anything

- [ ] Remove from `Brewfile` / `.tool-versions` / `.zsh_plugins.txt`
- [ ] Remove the corresponding row from `docs/inventory.md`
- [ ] Remove from `setup.sh`
- [ ] Remove from `verify.sh`

---

## 5. README is orientation only

`README.md` must never contain:
- Lists of tool or app names (link to `docs/inventory.md`)
- Keybinding tables (link to `docs/ghostty-cheatsheet.md` or `docs/modern-cli-cheatsheet.md`)
- Command examples that are already in a cheatsheet (link to the cheatsheet)
- Version numbers (link to `.tool-versions`)
- Plugin names (link to `.zsh_plugins.txt`)

When editing README, ask: "does this content already exist in a cheatsheet or inventory?" If yes, replace with a link.

---

## 6. verify.sh must stay in sync

`verify.sh` is the contract that the setup is complete and correct. Keep it in sync:

- New CLI binary installed → add to the `check_command` loop
- New GUI app installed → add to the `APPS` array
- New symlink added in `setup.sh` → add a `check_symlink` call
- New config file added → add `check_contains` or `check_json` assertions for its critical settings
- New Zsh plugin added → add a `check_contains` line for `.zsh_plugins.txt`
- New `.zshrc` initialization added → add a `check_contains` line for `.zshrc`

---

## 7. If the repo does not have the answer

1. **Say so explicitly.**
2. **Search the web** using the WebSearch tool. Prefer official docs and release notes over blog posts.
3. **Update the repo** if the answer is stable and reusable — place it in the most relevant `docs/*-cheatsheet.md`. Match existing tone: skimmable, commands first, gotchas where they matter. Do this proactively in Agent sessions.
