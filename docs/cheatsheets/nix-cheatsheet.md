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
| `flake.nix` | Inputs (nixpkgs, nix-darwin, nix-homebrew, home-manager) and the `darwinConfigurations."mac"` output |
| `configuration.nix` | macOS system defaults (`system.defaults`), and Homebrew — GUI apps (casks), asdf + its build deps, and the two tapped CLI tools not worth moving to Nix |
| `home.nix` | User-level: CLI tools available in nixpkgs (`home.packages`), shell/prompt/fzf/zoxide/atuin config (`programs.*`), and every dotfile symlink |

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
# typos (e.g. "git-delta" instead of nixpkgs' actual name "delta").
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

**GUI app, or a tool that isn't in nixpkgs / not worth moving:** add it to `configuration.nix`'s `homebrew.casks` (GUI apps) or `homebrew.brews` (CLI, including anything tapped from a third-party repo like `hashicorp/tap/terraform`).

**CLI tool that exists in nixpkgs:** add it to `home.nix`'s `home.packages` list. Check it exists first — the nixpkgs name doesn't always match the Homebrew formula name (e.g. Homebrew's `git-delta` is just `delta` in nixpkgs; `nix build --dry-run` will tell you immediately with `error: undefined variable '<name>'` if you guess wrong).

Either way:

```bash
./rebuild.sh
```

No separate "install" step — the switch both builds and applies.

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

If it's a `.app` bundle, or a CLI tool that isn't in nixpkgs (or isn't worth moving), it's Homebrew (`configuration.nix`). If it's a CLI tool available in nixpkgs, it's `home.packages` in `home.nix`. See [[homebrew-cheatsheet]] for the general Homebrew-vs-Nix package boundary this repo draws.

**Q: What does `darwin-rebuild switch --flake .#mac` mean, exactly?**

`.#mac` refers to the `darwinConfigurations."mac"` output defined in `flake.nix` (`.` = "this directory's flake"). If you ever rename the host label, it has to change in three places — `flake.nix`, `rebuild.sh`, and `bootstrap.sh` — all at once.

**Q: Why keep asdf instead of managing language runtimes in Nix too?**

Nix pins global versions much like asdf's fallback, but loses asdf's effortless per-project `.tool-versions` override — a directory-scoped file asdf auto-detects walking up the tree. Nix's per-project story is devshells/flakes/direnv, a heavier workflow. This repo keeps asdf deliberately.

**Q: `nix build --dry-run` says `error: undefined variable 'some-package'` — now what?**

The nixpkgs attribute name doesn't match what you typed. Search <https://search.nixos.org/packages> for the real name before adding it to `home.packages`.
