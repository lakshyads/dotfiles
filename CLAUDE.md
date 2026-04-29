# Claude Code Rules for this Dotfiles Repo

## 1. Always search this repo first

Before answering any question about this Mac dev setup, shell tools, CLI tools, configs, or anything that could be documented here — **read the repo first**.

### Where to look (in order)

| Question type | Search here first |
|---|---|
| How-to / CLI reference | `docs/` cheat sheets (see index below) |
| Bootstrap / what's installed | `setup.sh`, `verify.sh`, `Brewfile`, `.tool-versions` |
| Live config / "what is set?" | Root dotfiles: `.zshrc`, `starship.toml`, `ghostty-config` |
| Setup walkthrough / daily commands | `README.md` |

### docs/ index

See [`README.md` — Cheat Sheets & References](README.md#cheat-sheets--references) for the full annotated index. Key lookup:

| Topic | File |
|-------|------|
| Installed software (what, how) | `docs/inventory.md` |
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

Prefer `rg` over `grep` — it's faster, respects `.gitignore`, and is already installed in this setup.

## 2. If the repo does not have the answer

1. **Say so explicitly** — tell the user the repo doesn't cover this yet.
2. **Search the web** for the latest, up-to-date answer using the WebSearch tool. Prefer official docs and release notes (Homebrew, asdf, Ghostty, etc.) over random blog posts.

## 3. After finding the answer from the web — update the repo

When the answer is stable and reusable (not one-off), **add it to the knowledge base**:

- Put it in the most relevant `docs/*-cheatsheet.md`.
- For very common workflows, add a short subsection to `README.md`.
- For a brand-new topic not covered by any existing cheat sheet, create `docs/<topic>-cheatsheet.md`.
- Match existing tone: skimmable, commands first, gotchas where they matter.
- Do this proactively in Agent sessions unless the user asked for guidance only.

## 4. Keep the inventory in sync

Whenever `Brewfile` or `.tool-versions` changes (add, remove, or version bump), **also update `docs/inventory.md`**:

- Adding a cask → add a row to the GUI Applications table in `docs/inventory.md`.
- Adding a formula → add a row to the appropriate CLI tools section in `docs/inventory.md`.
- Adding a language → add a row to the Language Runtimes table in `docs/inventory.md`; versions stay only in `.tool-versions`.
- Removing anything → remove the corresponding row from `docs/inventory.md`.
- Also update `verify.sh` if the change affects what gets smoke-tested (GUI apps array or CLI tools list).
