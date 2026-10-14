#!/usr/bin/env bash
# npm-globals.sh — Install global npm CLIs declared in home/npm-globals.txt.
#
# Usage:
#   ./npm-globals.sh          # sync: install missing packages, enforce pins (bootstrap.sh, rebuild.sh)
#   ./npm-globals.sh update   # sync + upgrade every unpinned package to latest (update.sh)
#   ./npm-globals.sh check    # report only; exit 1 if anything is missing or off-pin (verify.sh)
#
# Packages go into a fixed prefix (~/.local/share/npm-global) rather than
# asdf's per-Node-version global dir, so they survive Node upgrades in
# .tool-versions. home.nix puts its bin/ on PATH and exports the same
# NPM_CONFIG_PREFIX, so `npm i -g` / `pi update --self` land here too.

set -uo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIST="$DOTFILES_DIR/home/npm-globals.txt"
MODE="${1:-sync}"

export NPM_CONFIG_PREFIX="${NPM_CONFIG_PREFIX:-$HOME/.local/share/npm-global}"
export PATH="$NPM_CONFIG_PREFIX/bin:${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

if [[ -t 1 ]]; then
  G=$'\033[0;32m' Y=$'\033[0;33m' B=$'\033[0;34m' R=$'\033[0m'
else
  G='' Y='' B='' R=''
fi
info()  { printf "${B}  →  ${R}%s\n" "$*"; }
done_() { printf "${G}  ✓  ${R}%s\n" "$*"; }
warn()  { printf "${Y}  !  ${R}%s\n" "$*" >&2; }

case "$MODE" in
  sync|update|check) ;;
  *) echo "usage: $0 [sync|update|check]" >&2; exit 2 ;;
esac

if ! command -v npm >/dev/null 2>&1; then
  warn "npm not found — install Node via asdf first (./bootstrap.sh)"
  exit 1
fi
mkdir -p "$NPM_CONFIG_PREFIX"

# Prints name<TAB>version for everything installed in the prefix.
list_installed() {
  npm ls -g --depth=0 --json 2>/dev/null | node -e '
    let s = ""; process.stdin.on("data", d => s += d).on("end", () => {
      const deps = (s && JSON.parse(s).dependencies) || {};
      for (const [n, v] of Object.entries(deps)) console.log(n + "\t" + (v.version || ""));
    });'
}
installed="$(list_installed)"
installed_version() { awk -F'\t' -v n="$1" '$1 == n { print $2 }' <<<"$installed"; }

status=0
install() {
  local name="$1" spec="$2" was="$3"
  info "Installing $spec (was ${was:-not installed}) …"
  if npm install -g --no-fund --no-audit "$spec" >/dev/null; then
    installed="$(list_installed)"
    done_ "$name@$(installed_version "$name")"
  else
    warn "$spec install failed"; status=1
  fi
}

declared=()
while IFS= read -r line; do
  line="${line%%#*}"
  line="$(xargs <<<"$line")"
  [[ -z "$line" ]] && continue

  # Scoped names start with "@", so only an "@" after position 0 is a version.
  rest="${line:1}"
  if [[ "$rest" == *@* ]]; then
    name="${line:0:1}${rest%@*}" pin="${rest##*@}"
  else
    name="$line" pin=""
  fi
  declared+=("$name")
  have="$(installed_version "$name")"

  if [[ -n "$pin" ]]; then
    if [[ "$have" == "$pin" ]]; then
      done_ "$name@$pin (pinned)"
    elif [[ "$MODE" == check ]]; then
      warn "$name: installed=${have:-none}, pinned=$pin"; status=1
    else
      install "$name" "$name@$pin" "$have"
    fi
  elif [[ -z "$have" ]]; then
    if [[ "$MODE" == check ]]; then
      warn "$name: not installed"; status=1
    else
      install "$name" "$name@latest" ""
    fi
  elif [[ "$MODE" == update ]]; then
    install "$name" "$name@latest" "$have"
  else
    done_ "$name@$have"
  fi
done <"$LIST"

# `npm` itself only shows up here if someone ran `npm i -g npm`; ignore it.
while IFS=$'\t' read -r name _; do
  [[ -z "$name" || "$name" == npm ]] && continue
  [[ " ${declared[*]} " == *" $name "* ]] || warn "$name is installed but not in home/npm-globals.txt"
done <<<"$installed"

exit "$status"
