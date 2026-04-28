# asdf Cheat Sheet & Best Practices

A reference for the day-to-day and the "I set this up months ago and now I need to remember how" moments. Targets asdf `0.16+` (the Go rewrite); older `source asdf.sh` syntax is deprecated and not covered here.

Official docs: <https://asdf-vm.com>

---

## Table of Contents

- [Plugin Management](#plugin-management)
- [Installing Versions](#installing-versions)
- [Setting Versions](#setting-versions)
- [Inspecting State](#inspecting-state)
- [Uninstalling](#uninstalling)
- [The `.tool-versions` File Format](#the-tool-versions-file-format)
- [Environment Variables](#environment-variables)
- [CI/CD Integration](#cicd-integration)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

---

## Plugin Management

Plugins are how asdf learns about a language or tool. Each runtime (Node, Python, Go, Ruby, etc.) has its own plugin.

```bash
# Add a plugin by short name (from the community registry)
asdf plugin add nodejs
asdf plugin add python
asdf plugin add golang
asdf plugin add java

# Add a plugin from an arbitrary git URL
asdf plugin add terraform https://github.com/asdf-community/asdf-hashicorp.git

# List installed plugins
asdf plugin list
asdf plugin list --urls --refs    # show git URL and ref of each

# Browse every plugin in the registry
asdf plugin list all

# Update plugins to their latest commit
asdf plugin update nodejs
asdf plugin update --all

# Remove a plugin (also removes all installed versions of its tool)
asdf plugin remove nodejs
```

---

## Installing Versions

```bash
# Install a specific version
asdf install nodejs 24.15.0
asdf install python 3.13.13

# Install the latest stable version
asdf install nodejs latest

# Install the latest matching a prefix
asdf install nodejs latest:22       # latest in the 22.x series
asdf install python latest:3.11     # latest in the 3.11.x series

# Install everything listed in .tool-versions (run this in your project root)
asdf install
```

**Speed tip:** Installing Python compiles from source by default; expect a few minutes. Node and Go install prebuilt binaries and finish in seconds.

---

## Setting Versions

asdf resolves versions in this order, first match wins:

1. `ASDF_${TOOL}_VERSION` environment variable
2. Nearest `.tool-versions` file (walks up from current dir)
3. `~/.tool-versions` (global fallback)
4. Nothing set → command fails with "No version is set"

```bash
# Project-local (writes to ./.tool-versions in current dir)
asdf set nodejs 24.15.0

# Global default (writes to ~/.tool-versions)
asdf set -u nodejs 24.15.0
asdf set --home nodejs 24.15.0       # same as -u

# Write to an existing .tool-versions in the nearest parent dir
asdf set -p nodejs 24.15.0

# Use the latest version
asdf set nodejs latest

# Fall back to the system-installed version for a tool
asdf set python system

# Per-shell override (doesn't touch any file)
export ASDF_NODEJS_VERSION=20.18.0
```

---

## Inspecting State

```bash
# Show the resolved version and where it came from for every active tool
asdf current

# Just one tool
asdf current nodejs

# List versions you have installed locally
asdf list nodejs
asdf list nodejs 24         # filter to 24.x

# List every version available for install
asdf list all nodejs
asdf list all nodejs 24     # filter to 24.x

# Show the latest stable version without installing
asdf latest nodejs
asdf latest --all           # for every installed plugin

# Find the path to an installed binary
asdf which node             # prints the shim-resolved path
asdf where nodejs           # prints the install directory

# Print environment info (useful when reporting bugs)
asdf info
```

---

## Uninstalling

```bash
# Remove a specific installed version
asdf uninstall nodejs 20.18.0

# Remove an entire plugin and all its installed versions
asdf plugin remove nodejs
```

---

## The `.tool-versions` File Format

Plain text, one tool per line, `name space version`:

```
# .tool-versions
nodejs  24.15.0
python  3.13.13
golang  1.26.2
java    openjdk-25.0.2

# Comments are supported
# rust  1.75.0   # uncomment to enable Rust
```

**Java version naming:** the Java plugin uses distributor-prefixed version strings (e.g. `openjdk-25.0.2`, `temurin-21.0.4+7.0.LTS`). Run `asdf list all java` to see available versions. The prefix matters — `25.0.2` alone will not match.

**Supported version formats:**

| Format | Meaning |
|---|---|
| `24.15.0` | Exact released version. Prebuilt binary if available, else compiled. |
| `ref:v1.0.2` | Specific git tag, commit, or branch. Always compiled. |
| `path:~/src/node` | Use a local custom build. For language developers. |
| `system` | Pass through to whatever is on `$PATH` outside asdf. |

**Multi-version fallback** (space-separated on the same line). asdf tries them in order:

```
python 3.13.13 3.11.9 system
```

---

## Environment Variables

The most useful ones; see [the full reference](https://asdf-vm.com/manage/configuration.html) for the rest.

| Variable | Effect |
|---|---|
| `ASDF_${TOOL}_VERSION` | Override tool version for this shell only (e.g. `ASDF_NODEJS_VERSION=20.18.0`) |
| `ASDF_DATA_DIR` | Where plugins, installs, and shims live. Default: `~/.asdf` |
| `ASDF_CONFIG_FILE` | Path to `.asdfrc`. Default: `~/.asdfrc` |
| `ASDF_CONCURRENCY` | Cores to use when compiling. Default: `auto` (detects) |

---

## CI/CD Integration

**GitHub Actions:**

```yaml
- uses: actions/checkout@v4

- uses: asdf-vm/actions/install@v3
  # Reads .tool-versions from the repo root and installs everything
```

That's it for the common case. The action handles plugin add + install in one step.

**Fallback approach (any CI):**

```bash
# Install asdf
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.18.1
export PATH="$HOME/.asdf/shims:$PATH"

# Add plugins for whatever's in .tool-versions
for plugin in $(awk '{print $1}' .tool-versions); do
  asdf plugin add "$plugin" || true
done

asdf install
```

**Docker:** asdf is usually overkill inside containers. Prefer a pinned base image (`node:24-alpine`, `python:3.12-slim`) since the version is already baked in and you avoid the cost of asdf startup overhead per build.

---

## Best Practices

### Commit `.tool-versions` to every repo

This is the single most important habit. It ensures:
- Every developer's machine matches
- CI matches developer machines
- Production matches CI (when the same `.tool-versions` is used in deploy)
- The "it works on my machine" class of bug disappears

### Pin exact versions, not `latest`

```
# Bad: reproducibility drifts over time
nodejs  latest

# Good: deterministic
nodejs  24.15.0
```

`latest` resolves at install time, so two developers who onboard a month apart end up on different versions.

### Keep `.tool-versions` minimal

Only list what the project actually needs. Don't declare Ruby in a pure Node project. The file is read on every `cd` into the directory; extra entries add latency and confusion.

### Match your CI matrix to `.tool-versions`

If you want to test against Node 22 AND 24, the test matrix handles that. But the `.tool-versions` file should reflect the *primary* supported version, not all of them.

### Never edit `.tool-versions` by hand for new entries

Use `asdf set` instead. It enforces the format, checks the plugin is installed, and won't silently create a broken file. (Editing is fine for removing entries or tweaking comments.)

### Run `asdf install` after pulling

When a teammate bumps a version in `.tool-versions`, `git pull` gets you the new version number but not the binary. Running commands will error with "No version is set for command ... 3.13.14 installed: 3.13.13". Fix: `asdf install`.

Consider wiring this into a git hook or `direnv`.

### Don't alias your tool commands

Leave `node`, `python`, `go` alone. asdf's whole design relies on these being resolved through shims. If you alias `node` to some custom path, asdf's version switching silently stops working.

### Reshim after global installs

If a tool you install uses `npm install -g foo` or `go install ...` to install sub-binaries, asdf may not know about them yet:

```bash
asdf reshim nodejs
asdf reshim golang
```

### Shell integration

Make sure this is near the top of your `~/.zshrc` (before anything that calls `node`, `python`, etc.):

```bash
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
```

The old `. asdf.sh` / `source asdf.sh` approach is from pre-0.16 and is no longer needed.

---

## Troubleshooting

**"No version is set for command ..."**

The `.tool-versions` references a version you haven't installed:

```bash
asdf install        # installs everything declared in .tool-versions
```

**`node` / `python` / `go` returns "command not found" after install**

Shim directory probably isn't on `$PATH`. Check:

```bash
echo $PATH | tr ':' '\n' | grep asdf
# Should show something like /Users/you/.asdf/shims
```

If empty, you haven't added the `PATH` export to your shell config.

**Command runs but uses the wrong version**

Check what asdf thinks is active, and where it's coming from:

```bash
asdf current
```

A common culprit: `ASDF_NODEJS_VERSION` set in your env is overriding `.tool-versions`. Unset it:

```bash
unset ASDF_NODEJS_VERSION
```

**Installed a global npm/gem/cargo package but the binary isn't found**

Reshim:

```bash
asdf reshim nodejs
```

**Python install fails with "missing openssl" / "readline"**

macOS Python builds need these as brew deps:

```bash
brew install openssl@3 readline xz
```

Then reinstall:

```bash
asdf uninstall python 3.13.13
asdf install python 3.13.13
```

**Plugin is out of date (e.g. missing a new language version)**

```bash
asdf plugin update nodejs       # or --all
asdf list all nodejs            # confirm the version you want now appears
```

**Everything's broken, I want to start over**

```bash
rm -rf ~/.asdf                  # wipes plugins, installs, shims
# Then reinstall asdf via Homebrew and re-run `asdf install` in your project
```
