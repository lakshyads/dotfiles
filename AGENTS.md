# Claude Code Rules for this Dotfiles Repo

## 1. Always search this repo first

Before answering any question about this Mac dev setup, shell tools, CLI tools, configs, or anything that could be documented here — **read the repo first**.

### Where to look (in order)

| Question type | Search here first |
|---|---|
| What is installed / how | `docs/inventory.md` |
| How-to / CLI reference | `docs/cheatsheets/` (see index below) |
| Bootstrap / wiring | `flake.nix`, `configuration.nix`, `home.nix`, `bootstrap.sh`, `rebuild.sh`, `verify.sh` |
| Live config / "what is set?" | `home/.config/{wezterm,ghostty,nvim,herdr,linearmouse}/`, `home/.baby-menu/`, `home.nix`'s `programs.zsh` block and `starship.toml` |
| Setup walkthrough / daily commands | `README.md` |

### docs/ index

See [`README.md` — Cheat Sheets & References](README.md#cheat-sheets--references) for the full annotated index. Key lookup:

| Topic | File |
|-------|------|
| Installed software (what, how installed) | `docs/inventory.md` |
| Nix / nix-darwin / home-manager workflow | `docs/cheatsheets/nix-cheatsheet.md` |
| Homebrew (via nix-homebrew) | `docs/cheatsheets/homebrew-cheatsheet.md` |
| Language runtimes | `docs/cheatsheets/asdf-cheatsheet.md` |
| Terminal keybindings / config | `docs/cheatsheets/ghostty-cheatsheet.md` |
| Git workflows | `docs/cheatsheets/git-cheatsheet.md` |
| Git TUI | `docs/cheatsheets/lazygit-cheatsheet.md` |
| Modern CLI tools | `docs/cheatsheets/modern-cli-cheatsheet.md` |
| Claude Code CLI | `docs/cheatsheets/claude-code-cheatsheet.md` |
| Cursor IDE | `docs/cheatsheets/cursor-cli-cheatsheet.md` |
| Docker | `docs/cheatsheets/docker-cheatsheet.md` |
| Vim/Neovim keybindings | `docs/cheatsheets/vim-cheat-sheet.md` |

### How to search

Use `rg` (ripgrep) to find relevant content fast before doing a full file read:

```
rg "<keyword>" docs/ -l
rg "<keyword>" <matched-file> -n
```

---

## 2. Sources of truth — one file owns each type of data

Never duplicate these. Every other place must link, not repeat.

| Data | Authoritative file | What goes here |
|------|--------------------|----------------|
| Every CLI tool and GUI app (formulae + casks) | `configuration.nix`'s `homebrew` block | Every `homebrew.brews` / `homebrew.casks` entry. CLI tools live here, not in Nix, so `brew upgrade <tool>` on the spot and `./update.sh` converge. |
| Global npm CLIs (e.g. `pi`, `*-axi`) | `home/npm-globals.txt` | One package per line; bare name = latest, `name@version` = pinned. Installed by `./npm-globals.sh` into `~/.local/share/npm-global`, so on-the-spot `npm i -g` lands there too. |
| Third-party agent skills (e.g. `lavish`) | `home/agent-skills.txt` | One `<owner/repo> <skill>` per line, always latest. Installed by `./agent-skills.sh` via `npx skills add -g`, so on-the-spot `npx skills add`/`update` converge. The repo's own skills (`home/skills/`) are linked by `home.nix` instead. |
| Self-updating native installers (Claude Code `claude`, Cursor `agent`) | `bootstrap.sh` (install), `update.sh` (`claude update`, `agent update`) | Live in `~/.local/bin`; they update themselves. |
| Nix-managed content (config only, plus fonts and zsh completion definitions) | `home.nix` | Config files, shell setup, symlinks. **No CLI tools in `home.packages`** — a Nix copy can't be upgraded individually and gets shadowed by stray Homebrew copies. |
| Zsh plugins, aliases, keybinds, Starship prompt | `home.nix`'s `programs.zsh` block and `xdg.configFile."starship.toml"` | Antidote is retired — native home-manager zsh plugin toggles replace it. There is no more standalone plugin-list file. |
| Dotfile symlink targets | `home.nix`'s `home.file` / `mkOutOfStoreSymlink` entries | Every path under `~` that should point back into this repo |
| Language runtime versions | `.tool-versions` | Version numbers only — never written in docs. Runtimes stay asdf-managed by design (not Nix-managed) — see README's Design Decisions. |
| Human-readable inventory | `docs/inventory.md` | What's installed, how, one row per item |
| Detailed command references | `docs/cheatsheets/*-cheatsheet.md` | Full usage, flags, examples, gotchas |
| Orientation + links | `README.md` | Overview only — links to cheatsheets, no duplicated content |

---

## 3. No duplicate content across docs

**One source, everywhere else links.**

- If a table, code block, or list already exists in one doc, all other docs must link to it — never copy it.
- `README.md` is orientation only: it describes categories and links out. It does not contain tool lists, keybinding tables, command blocks, or version numbers.
- Version numbers appear only in `.tool-versions`. Docs name the language (e.g. "Node.js") but never the version.
- Package lists appear only in `configuration.nix` (Homebrew) and `home/npm-globals.txt` (npm). Docs say "see `configuration.nix`" rather than listing packages.
- When adding content from the web: place it in the single most relevant `docs/cheatsheets/*-cheatsheet.md`. Do not add it to README as well.

---

## 4. Adding a new tool, app, or runtime — full checklist

Work through every applicable item. Skipping any item leaves the repo inconsistent.

**Update convergence:** a tool must end up in the same state whether it's updated on the spot (`brew upgrade X`, `npm i -g X@latest`, `claude update`) or in bulk via `./update.sh`. Declarations state *presence* (plus optional pins), never minimum versions — so pick the channel whose own update command you'd naturally run.

### Adding a Homebrew cask (GUI app)

- [ ] Add to `configuration.nix`'s `homebrew.casks`
- [ ] Add a row to the GUI Applications table in `docs/inventory.md` (include "Installed via: `brew install --cask`" or "configuration.nix's homebrew.casks")
- [ ] Add to the `APPS` array in `verify.sh`
- [ ] If the app writes back to a config file, add a `home.file` entry in `home.nix` using `config.lib.file.mkOutOfStoreSymlink` (NOT plain `home.file`, which symlinks from the read-only Nix store) plus a `home.activation` script that backs up any pre-existing real file before the symlink lands — see the `linearmouse.json` pattern in `home.nix` (`home.activation.backupLinearMouseConfig`)
- [ ] Run `./rebuild.sh`

### Adding a CLI tool (Homebrew formula — the default for any CLI)

- [ ] Add to `configuration.nix`'s `homebrew.brews` (add a `homebrew.taps` entry too if it's from a third-party tap)
- [ ] If it needs shell init, add it by command name to `programs.zsh.initContent` — never via a home-manager `programs.<tool>` module, which installs a second, Nix-store copy
- [ ] Add a row to the appropriate CLI tools section in `docs/inventory.md` (include "Installed via: `brew install`")
- [ ] Add to the `check_from … /opt/homebrew/bin` loop in `verify.sh`
- [ ] Run `./rebuild.sh`

### Adding a global npm CLI (tools distributed on npm)

- [ ] Add the package to `home/npm-globals.txt` (bare name for latest, `name@version` to pin)
- [ ] Add a row to the appropriate CLI tools section in `docs/inventory.md` (include "Installed via: npm (`home/npm-globals.txt`)")
- [ ] Run `./npm-globals.sh` (or `./rebuild.sh`, which calls it) — `verify.sh` runs `./npm-globals.sh check`

### Adding a third-party agent skill

- [ ] Add `<owner/repo> <skill>` to `home/agent-skills.txt`
- [ ] Add a row to the third-party skills table in `docs/inventory.md`
- [ ] Run `./agent-skills.sh` (or `./rebuild.sh`, which calls it); `verify.sh` runs `./agent-skills.sh check`

### Adding a language runtime (asdf)

- [ ] Add to `.tool-versions` (version number goes here and nowhere else)
- [ ] Add a row to the Language Runtimes table in `docs/inventory.md` (language name and `.tool-versions` key only — no version number)
- [ ] Run `./bootstrap.sh` (registers the asdf plugin and runs `asdf install` for anything new in `.tool-versions`)
- [ ] Confirm the language's runtime-version check loop in `verify.sh` covers it

### Adding a zsh alias / keybind

- [ ] Add to `home.nix`'s `programs.zsh.shellAliases` (aliases) or `programs.zsh.initContent` (keybinds, env vars, PATH changes)
- [ ] Run `./rebuild.sh`

### Removing anything

- [ ] Remove from `configuration.nix` / `home.nix` / `.tool-versions` / `home/npm-globals.txt` (npm: also `npm rm -g <name>`) / `home/agent-skills.txt` (also `npx skills remove -g <name>`)
- [ ] Remove the corresponding row from `docs/inventory.md`
- [ ] Remove from `verify.sh` (`check_command` loop, `APPS` array, or `check_contains`/`check_resolves_to_repo` calls as applicable)
- [ ] Run `./rebuild.sh` — note `homebrew.onActivation.cleanup = "none"` means removed Homebrew packages are left installed but undeclared, not force-uninstalled; `brew uninstall` manually if you want it gone from disk too

---

## 5. README is orientation only

`README.md` must never contain:
- Lists of tool or app names (link to `docs/inventory.md`)
- Keybinding tables (link to `docs/cheatsheets/ghostty-cheatsheet.md` or `docs/cheatsheets/modern-cli-cheatsheet.md`)
- Command examples that are already in a cheatsheet (link to the cheatsheet)
- Version numbers (link to `.tool-versions`)
- Package lists (link to `configuration.nix` / `home/npm-globals.txt`)

When editing README, ask: "does this content already exist in a cheatsheet or inventory?" If yes, replace with a link.

---

## 6. verify.sh and nix flake check — two layers of contract

`nix flake check --no-build` (and `nix build .#darwinConfigurations.mac.system --dry-run`) is the **primary** contract now for anything declared in `configuration.nix`/`home.nix` — if a package or symlink is declared wrong, the flake fails to evaluate or build before you ever get to `verify.sh`. `verify.sh` itself now runs `nix flake check` as its first check, then covers what Nix genuinely can't express on its own:

- Whether things are *actually* wired up on THIS machine right now (not just declared correctly)
- GUI app presence and `/Applications` state (Nix can't verify sign-in state)
- asdf runtime versions matching `.tool-versions` (asdf is deliberately outside Nix's management)
- Git identity (still `bootstrap.sh`-driven, written directly to mutable `~/.gitconfig`; pager/merge/delta config is nix-managed via `programs.git` in `home.nix`, applied to `~/.config/git/config`)
- LinearMouse JSON content integrity (a write-back file, worth sanity-checking regardless of installer mechanism)

Keep `verify.sh` in sync:
- New CLI binary installed → add to the `check_from` loop for its channel (`/opt/homebrew/bin`, `~/.local/bin`, or the npm-global prefix), which also catches a copy from another channel shadowing it
- New GUI app installed → add to the `APPS` array
- New symlink added in `home.nix` → add a `check_resolves_to_repo` call (for edit-in-place files) or `check_nonempty` (for home-manager-generated files like `.zshrc`/`starship.toml`)
- New config file added → add `check_contains` or `check_json` assertions for its critical settings

---

## 7. If the repo does not have the answer

1. **Say so explicitly.**
2. **Search the web** using the WebSearch tool. Prefer official docs and release notes over blog posts.
3. **Offer to update the cheatsheet** if the answer is stable and reusable: suggest the most relevant `docs/cheatsheets/*-cheatsheet.md`, and wait for approval before editing it. Match existing tone: skimmable, commands first, gotchas where they matter.
