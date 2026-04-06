#!/usr/bin/env bash
#
# install_brew_apps.sh — install macOS applications via Homebrew.
#
# Reads two newline-delimited lists from apps/:
#   apps/osx_brew_formulae.txt   (CLI tools / libraries -> brew install)
#   apps/osx_brew_casks.txt      (GUI apps / fonts      -> brew install --cask)
#
# Blank lines and lines starting with '#' are ignored so the lists can
# be annotated. Safe to re-run; brew skips already-installed packages.
#
# Base deps (git, curl, vim, tmux, ghostty) are handled by dotbot in
# adamweld.conf.yaml — this script is for everything else.

set -euo pipefail

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FORMULAE_FILE="${BASEDIR}/apps/osx_brew_formulae.txt"
CASKS_FILE="${BASEDIR}/apps/osx_brew_casks.txt"

if [ "$(uname -s)" != "Darwin" ]; then
    echo "This script is macOS-only (detected $(uname -s))." >&2
    exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew not found. Run ./install first to bootstrap it." >&2
    exit 1
fi

# Strip comments and blank lines, emit one package name per line.
read_list() {
    local file="$1"
    [ -f "$file" ] || return 0
    sed -e 's/#.*$//' -e 's/[[:space:]]*$//' -e '/^[[:space:]]*$/d' "$file"
}

install_many() {
    local kind="$1"  # "formula" or "cask"
    local file="$2"
    local flag="$3"  # "" for formulae, "--cask" for casks

    local pkgs
    pkgs="$(read_list "$file")"
    if [ -z "$pkgs" ]; then
        echo "No ${kind}s listed in $(basename "$file"); skipping."
        return 0
    fi

    echo "Installing ${kind}s from $(basename "$file"):"
    # Install one at a time so a single failure doesn't abort the rest.
    local pkg
    while IFS= read -r pkg; do
        [ -z "$pkg" ] && continue
        echo "  -> brew install ${flag} ${pkg}"
        brew install ${flag} "$pkg" || echo "     (failed: $pkg)"
    done <<< "$pkgs"
}

echo "Updating Homebrew..."
brew update

install_many "formula" "$FORMULAE_FILE" ""
install_many "cask"    "$CASKS_FILE"    "--cask"

echo "Done."
