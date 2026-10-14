---
tag:
  - type/cheatsheet
  - topic/package-management
related:
  - "[[homebrew-cheatsheet]]"
  - "[[asdf-cheatsheet]]"
  - "[[modern-cli-cheatsheet]]"
---

# Nix / nix-darwin / home-manager Cheat Sheet

A reference for the nix-darwin + home-manager setup this repo uses to manage macOS system defaults, Homebrew (via nix-homebrew), and dotfiles declaratively. Covers the daily workflow, validation before applying, and rollback — the actual payoff of this whole setup.

Official docs: <https://nix-darwin.github.io/nix-darwin> · <https://nix-community.github.io/home-manager>

---

## Table of Contents

- [How This Repo Is Wired](#how-this-repo-is-wired)
- [Daily Workflow](#daily-workflow)
- [Validating Before You Apply](#validating-before-you-apply)
- [Rollback](#rollback)
- [Adding a Package](#adding-a-package)
- [Gotchas](#gotchas)
- [FAQ](#faq)

---

## How This Repo Is Wired

Three files, three jobs:

| File | Owns |
|---|---|
| `flake.nix` | Inputs (nixpkgs 26.05, nix-darwin, nix-homebrew, home-manager) and the `darwinConfigurations."mac"` output |
| `configuration.nix` | macOS system defaults (`system.defaults`), and Homebrew — every CLI tool (`homebrew.brews`, including asdf + its build deps) and GUI app (`homebrew.casks`) |
| `home.nix` | User-level config only: zsh (`programs.zsh`, including shell init for zoxide/fzf/starship/atuin), Starship prompt (`xdg.configFile."starship.toml"`), git config (`programs.git`, `package = null`), every dotfile symlink, plus fonts and `zsh-completions` (the only `home.packages` entries) |

`bootstrap.sh` is the one-time entry point for a fresh Mac (installs Nix, does the first switch, then registers asdf runtimes and prompts for git identity). `rebuild.sh` is what you reach for day-to-day after editing config.

---

## Daily Workflow

Edit `configuration.nix` or `home.nix`, then:

```bash
./rebuild.sh
```

Under the hood this runs:

```bash
sudo /run/current-system/sw/bin/darwin-rebuild switch --flake .#mac
```

**Why the full path with `sudo`?** `sudo` resets `PATH` and won't find `darwin-rebuild` on it even though your regular shell can. This is also why `bootstrap.sh`'s first-ever switch uses `sudo nix run nix-darwin/nix-darwin-26.05#darwin-rebuild -- switch --flake .#mac` instead — `darwin-rebuild` doesn't exist as an installed command yet on a brand new machine.

---

## Validating Before You Apply

Two levels, cheapest first:

```bash
# Fast structural check — evaluates the flake, no building. Catches syntax
# errors and type mismatches in seconds.
nix flake check --no-build

# Full dry-run build — actually resolves and would-build every derivation,
# without touching the live system. Slower, but catches real package-name
# typos (e.g. a misspelled nerd-fonts attribute in home.packages).
nix build .#darwinConfigurations.mac.system --dry-run
```

`./verify.sh` runs `nix flake check --no-build` as its very first check — a failing flake fails there before anything else is even checked.

---

## Rollback

This is the actual point of the whole migration: every `darwin-rebuild switch` creates a new, numbered **generation**. Switching is atomic — if a new generation is bad, you go back to the last good one instantly, no manual undo required:

```bash
# Roll back to the previous generation
sudo darwin-rebuild --rollback

# List all generations
darwin-rebuild --list-generations

# Roll back to a specific generation number
sudo darwin-rebuild switch --flake .#mac --rollback  # (or re-switch an older flake.lock commit)
```

Compare this to the old `setup.sh` + `Brewfile` model: there was no equivalent of "undo the last package change" — you'd have to manually `brew uninstall` and hope you remembered everything that changed.

---

## Adding a Package

**CLI tool:** add it to `configuration.nix`'s `homebrew.brews` (including anything tapped from a third-party repo like `hashicorp/tap/terraform`, plus a `homebrew.taps` entry). Not `home.packages` — a Nix copy can't be upgraded on the spot with `brew upgrade <tool>` and gets shadowed by stray Homebrew copies. If it needs config, declare that in `home.nix` (e.g. shell init in `programs.zsh.initContent`, by command name).

**GUI app:** add it to `configuration.nix`'s `homebrew.casks`.

**Global npm CLI:** add a line to `home/npm-globals.txt` (installed by `./npm-globals.sh`).

Then:

```bash
./rebuild.sh
```

No separate "install" step — the switch both builds and applies. It only installs what's missing, though; it never upgrades (`onActivation.autoUpdate` just refreshes Homebrew metadata). Versions move forward via `./update.sh` or `brew upgrade <tool>`.

---

## Gotchas

### `homebrew.onActivation.cleanup` — read this before touching it

nix-homebrew can force-uninstall any Homebrew package not declared in `configuration.nix`'s `homebrew.brews`/`homebrew.casks`, via `onActivation.cleanup = "zap"`. **This repo deliberately sets it to `"none"` instead** (see `configuration.nix`) — undeclared packages are left alone rather than force-removed. Given how much is installed here, `"zap"` is a real footgun: a package you `brew install`ed by hand outside the flake, or a typo that silently dropped an entry from `configuration.nix`, would get force-uninstalled on the next switch. Don't flip this to `"zap"` without first running `brew list --formula` / `brew list --cask` and confirming it matches `configuration.nix` exactly.

### `sudo` and `darwin-rebuild` don't mix without the full path

Covered above under [Daily Workflow](#daily-workflow) — `rebuild.sh` and `bootstrap.sh` both already handle this correctly, but if you ever run `darwin-rebuild` manually, remember `sudo darwin-rebuild switch ...` alone will fail with `command not found`.

### `flake.lock` can end up root-owned

Any command run with `sudo` (like the switch itself) can update `flake.lock` as root, which then blocks your normal user from running `nix flake check`/`nix build` afterwards ("Permission denied"). Fix:

```bash
sudo chown $(whoami) flake.lock
```

### home-manager refuses to overwrite existing symlinks — even ones it should own

If a path `home.nix` wants to manage already has a real file or a foreign symlink at that location (e.g. left over from a pre-Nix setup), activation may print `Existing file '...' would be clobbered` and abort, even with `backupFileExtension` set in `flake.nix`. This has been observed specifically for home-manager-*generated* files (`.zshrc`, `~/.config/starship.toml`) rather than plain `mkOutOfStoreSymlink` targets. Fix: move the conflicting file aside by hand before re-running the switch:

```bash
mv ~/.zshrc ~/.zshrc.hm-backup
```

---

## FAQ

**Q: How do I know if a package should go in `configuration.nix` or `home.nix`?**

If it's something you install — a CLI tool or a `.app` bundle — it's Homebrew (`configuration.nix`). If it's config for that tool (shell init, prompt, git settings, a dotfile symlink), it's `home.nix`. Fonts and `zsh-completions` are the only packages still in `home.packages`. See [[homebrew-cheatsheet]] for the general Homebrew-vs-Nix boundary this repo draws.

**Q: What does `darwin-rebuild switch --flake .#mac` mean, exactly?**

`.#mac` refers to the `darwinConfigurations."mac"` output defined in `flake.nix` (`.` = "this directory's flake"). If you ever rename the host label, it has to change in three places — `flake.nix`, `rebuild.sh`, and `bootstrap.sh` — all at once.

**Q: Why keep asdf instead of managing language runtimes in Nix too?**

Nix pins global versions much like asdf's fallback, but loses asdf's effortless per-project `.tool-versions` override — a directory-scoped file asdf auto-detects walking up the tree. Nix's per-project story is devshells/flakes/direnv, a heavier workflow. This repo keeps asdf deliberately.

**Q: `nix build --dry-run` says `error: undefined variable 'some-package'` — now what?**

The nixpkgs attribute name doesn't match what you typed (e.g. a font in `home.packages`, or a `pkgs.*` reference in `home.nix`). Search <https://search.nixos.org/packages> for the real name. CLI tools don't belong in `home.packages` — add them to `configuration.nix`'s `homebrew.brews` instead.
