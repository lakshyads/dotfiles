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

- `docs/homebrew-cheatsheet.md` — install, update, upgrade, uninstall, Brewfile, casks, cleanup
- `docs/asdf-cheatsheet.md` — plugin management, version install/set, `.tool-versions`, CI
- `docs/ghostty-cheatsheet.md` — keybindings, splits, Quick Terminal, themes, SSH, troubleshooting
- `docs/git-cheatsheet.md` — daily workflow, branching, rebasing, undoing, stashing, tags
- `docs/lazygit-cheatsheet.md` — panel model, staging, interactive rebase, line-level staging
- `docs/modern-cli-cheatsheet.md` — ripgrep, fd, bat, eza, zoxide, fzf, atuin, delta, dust, btop, tldr
- `docs/claude-code-cheatsheet.md` — CLI flags, slash commands, keybindings, CLAUDE.md, hooks, MCP
- `docs/cursor-cli-cheatsheet.md` — agent modes, slash commands, MCP, rules, subagents, scripting

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
