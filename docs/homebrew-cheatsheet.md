# Homebrew Cheat Sheet & Best Practices

A reference for Homebrew 5.x on macOS (2026). Covers installation, daily commands, Brewfile workflows, and the troubleshooting you'll actually need.

Official docs: <https://docs.brew.sh>

---

## Table of Contents

- [Why Homebrew?](#why-homebrew)
- [Installation](#installation)
- [Essential Daily Commands](#essential-daily-commands)
- [Installing GUI Apps with Cask](#installing-gui-apps-with-cask)
- [Brewfile: Declarative Setup](#brewfile-declarative-setup)
- [Real-World Scenarios](#real-world-scenarios)
- [FAQ](#faq)
- [Common Pitfalls](#common-pitfalls)

---

## Why Homebrew?

Homebrew installs packages into their own directories and symlinks them into `/opt/homebrew` (Apple Silicon) or `/usr/local` (Intel Macs). This isolation means:

- **No sudo required** for installations
- **Easy uninstall** with `brew uninstall`
- **Clean upgrades** with `brew upgrade`
- **Dependency management** handled automatically

For GUI applications, Homebrew Cask extends this same philosophy to apps like VS Code, Docker, and Ghostty.

---

## Installation

Open Terminal and run:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

After installation, add Homebrew to your PATH (Apple Silicon Macs):

```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

Verify everything works:

```bash
brew --version
# Homebrew 5.x.x
```

---

## Essential Daily Commands

### Searching for Packages

```bash
# Search for a package
brew search postgresql
brew search jq

# Get info before installing (version, deps, build options)
brew info postgresql@17
brew info gh
```

### Installing Packages

```bash
# Install a formula (CLI tool or library)
brew install git
brew install wget
brew install jq

# Install a specific version
brew install postgresql@17
```

### Managing Your Installation

```bash
# List installed packages
brew list                       # everything
brew list --formula             # just CLI tools
brew list --cask                # just GUI apps

# See what's outdated
brew outdated

# Upgrade everything
brew upgrade

# Upgrade a specific package
brew upgrade git

# Uninstall a package
brew uninstall wget

# Clean up old versions
brew cleanup
```

### Diagnosing Problems

```bash
# Check for issues (unlinked kegs, missing deps, permissions, config)
brew doctor

# Show Homebrew's view of a package (dependencies, dependents, paths)
brew info <name>
brew deps <name>                # what a package depends on
brew uses --installed <name>    # what installed packages depend on it
```

---

## Installing GUI Apps with Cask

Homebrew Cask handles macOS applications. No more dragging `.dmg` files around:

```bash
# Development tools
brew install --cask ghostty              # Terminal emulator
brew install --cask visual-studio-code   # Editor
brew install --cask cursor               # AI-native code editor
brew install --cask docker-desktop
brew install --cask postman

# Productivity
brew install --cask rectangle            # Keyboard-driven window tiling
brew install --cask maccy                # Clipboard history manager
brew install --cask appcleaner           # Clean uninstalls
brew install --cask 1password

# Browsers
brew install --cask google-chrome
brew install --cask firefox

# Communication
brew install --cask slack
brew install --cask discord
```

**Tip:** `brew list --cask` shows all installed GUI apps.

**Gotcha:** some casks (Maccy, Rectangle, Ghostty with global hotkeys) need macOS Accessibility permission on first launch. Homebrew installs the app; you grant the permission in System Settings > Privacy & Security > Accessibility.

---

## Brewfile: Declarative Setup

A **Brewfile** turns your Homebrew setup into a single file you can commit, share, and reproduce. It's the backbone of any reproducible macOS dev environment.

### Creating a Brewfile

```bash
# Generate from current installation
brew bundle dump

# Include human-readable descriptions for each entry
brew bundle dump --describe

# Overwrite an existing Brewfile
brew bundle dump --force
```

### Example Brewfile

```ruby
# Brewfile

# Core CLI tools
brew "git"
brew "gh"
brew "jq"
brew "tree"
brew "wget"

# Language version manager (runtimes declared separately in .tool-versions)
brew "asdf"

# Databases (optional if you run everything in Docker)
brew "postgresql@17"
brew "redis"

# GUI apps
cask "docker-desktop"
cask "ghostty"
cask "visual-studio-code"
cask "cursor"
cask "rectangle"
cask "1password"

# Fonts
cask "font-jetbrains-mono-nerd-font"
```

**Note:** Modern Brewfiles don't need explicit `tap "homebrew/core"`, `tap "homebrew/cask"`, or `tap "homebrew/bundle"` lines. These are built in since Homebrew 4.x.

### Using a Brewfile

```bash
# Install everything from a Brewfile in the current directory
brew bundle

# Install from a specific file
brew bundle --file=/path/to/Brewfile

# Dry-run: check what's missing without installing
brew bundle check

# List everything the Brewfile would install (useful for review)
brew bundle list --all

# Remove packages NOT declared in the Brewfile (destructive)
brew bundle cleanup
brew bundle cleanup --force      # actually removes instead of just listing
```

### Store Your Brewfile in Git

```bash
mkdir ~/dotfiles
cd ~/dotfiles
brew bundle dump
git init
git add Brewfile
git commit -m "Initial Brewfile"
git remote add origin git@github.com:username/dotfiles.git
git push -u origin main
```

Any new machine is then three commands away from your perfect setup:

```bash
git clone git@github.com:username/dotfiles.git
cd dotfiles
brew bundle
```

---

## Real-World Scenarios

### Scenario 1: Onboarding a New Developer

Commit a `Brewfile` to your team repo alongside `.tool-versions`:

```ruby
# team/Brewfile
brew "git"
brew "gh"
brew "asdf"
brew "starship"
brew "antidote"
brew "fzf"
brew "ripgrep"
brew "zoxide"
cask "ghostty"
cask "docker-desktop"
cask "visual-studio-code"
cask "font-jetbrains-mono-nerd-font"
```

Onboarding becomes:

```bash
git clone https://github.com/company/repo.git
cd repo
brew bundle          # installs Homebrew deps (including asdf)
asdf install         # reads .tool-versions and installs all runtimes
npm install          # or pip install -r requirements.txt, etc.
```

### Scenario 2: Resetting a Messy Mac

**Option A, reconcile with a known-good Brewfile** (recommended; non-destructive to your tracked setup):

```bash
# Save current state as a reference
brew bundle dump --describe --force --file=~/Brewfile.backup

# Remove anything not declared in your canonical Brewfile
brew bundle cleanup --force --file=~/dotfiles/Brewfile

# Ensure everything declared is installed and up to date
brew bundle --file=~/dotfiles/Brewfile

# Reclaim disk space from old versions
brew cleanup
```

**Option B, nuke and repave** (destructive; use when the system is genuinely broken):

```bash
brew bundle dump --describe --force --file=~/Brewfile.backup
brew uninstall --force $(brew list --formula)
brew uninstall --cask --force $(brew list --cask)
brew bundle --file=~/dotfiles/Brewfile
```

### Scenario 3: CI/CD Environment Setup

```yaml
# .github/workflows/test.yml
jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Homebrew
        uses: Homebrew/actions/setup-homebrew@main

      - name: Install Homebrew dependencies
        run: brew bundle

      - name: Install language runtimes via asdf
        uses: asdf-vm/actions/install@v3
        # reads .tool-versions automatically
```

**Production tip:** For stricter supply-chain hygiene, pin third-party actions to a full commit SHA (e.g. `Homebrew/actions/setup-homebrew@<sha>`) rather than a mutable branch.

---

## FAQ

**Q: How do I update Homebrew itself?**

```bash
brew update           # update Homebrew formulae metadata
brew upgrade          # upgrade installed packages
brew cleanup          # remove old versions
```

**Q: What's the difference between `brew install` and `brew install --cask`?**

- `brew install` installs command-line tools and libraries (formulae)
- `brew install --cask` installs macOS applications (`.app` bundles)

**Q: Where does Homebrew install things?**

| Location | Path |
|---|---|
| Apple Silicon prefix | `/opt/homebrew` |
| Intel Mac prefix | `/usr/local` |
| Casks | `$(brew --prefix)/Caskroom` |
| Logs | `$(brew --prefix)/var/log` |

**Q: How do I preview what would be installed?**

```bash
brew info <package>
brew bundle check --file=Brewfile
```

**Q: How do I pin a package at a version so `brew upgrade` doesn't touch it?**

```bash
brew pin postgresql@17
brew unpin postgresql@17        # allow upgrades again
```

**Q: How do I install multiple versions of the same tool side-by-side?**

Use versioned formulae when they exist (`postgresql@16` and `postgresql@17` can coexist). Otherwise use asdf for language runtimes. See the [asdf cheat sheet](asdf-cheatsheet.md).

---

## Common Pitfalls

### Permissions Issues

```bash
# Fix permissions (Apple Silicon)
sudo chown -R $(whoami) /opt/homebrew

# Or reinstall Homebrew entirely
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### PATH Issues

```bash
# Check PATH
echo $PATH | tr ':' '\n' | grep homebrew

# Add to PATH if missing
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### Cask Conflicts

```bash
# App already exists outside Homebrew (dragged from a DMG previously)
brew install --cask --force visual-studio-code
```

**Note:** Homebrew 5.0 deprecated the `--no-quarantine` flag. The project no longer wants to help bypass macOS Gatekeeper. If you hit quarantine issues with a legitimate app, address them via System Settings > Privacy & Security.

### "Command not found" after install

If `brew install <tool>` succeeds but `tool` isn't found:

```bash
# 1. Confirm Homebrew is on PATH
which brew          # should print /opt/homebrew/bin/brew

# 2. Confirm the tool is actually installed
brew list | grep <tool>

# 3. Reshim (rare; only for tools managed by asdf)
asdf reshim <plugin>

# 4. Restart your shell
exec zsh
```

### Brewfile `cleanup` removes something you want

`brew bundle cleanup` uninstalls any package not listed in the Brewfile. If you want to keep a one-off install:

```ruby
# Add it to Brewfile
brew "some-one-off-tool"
```

Or keep it outside `brew bundle` entirely and don't run `cleanup`.

### `brew doctor` warnings you can usually ignore

- **"Unbrewed header files found in /usr/local/include"** is leftover from a tool that doesn't go through Homebrew. Usually harmless.
- **"Git could not be found in your PATH"** at first install is normal until Xcode CLT is installed.
- **"You have MacPorts or Fink installed"** is fine if you're not actively using them.

If `brew doctor` reports something more specific (missing deps, broken symlinks), follow its suggestions directly.
