#!/bin/sh
# Install the Darpan helper (the `obsbot` binary) for your user. No sudo, no root.
#
#   curl -fsSL https://vrm-infra.github.io/darpan/install.sh | sh
#   curl -fsSL https://vrm-infra.github.io/darpan/install.sh | sh -s -- --uninstall
#
# It downloads the binary for your CPU from the latest release of vrm-infra/darpan,
# checks its SHA-256 against the release's SHA256SUMS, installs it to ~/.local/bin/obsbot
# and starts it at login as a systemd user service on http://127.0.0.1:8737.
#
# Test hook: DARPAN_BASE_URL replaces the release download URL.
set -eu

REPO="vrm-infra/darpan"
PAGE="https://vrm-infra.github.io/darpan/"
BASE="${DARPAN_BASE_URL:-https://github.com/$REPO/releases/latest/download}"
BIN_DIR="$HOME/.local/bin"
BIN="$BIN_DIR/obsbot"

say() { printf '%s\n' "$*"; }
die() { printf 'darpan: %s\n' "$*" >&2; exit 1; }

usage() {
    say "Usage: install.sh [--uninstall]"
    say "  (no option)   install or update the helper for your user"
    say "  --uninstall   stop the service and remove the helper"
}

fetch() { # fetch URL FILE
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL -o "$2" "$1" || die "download failed: $1"
    elif command -v wget >/dev/null 2>&1; then
        wget -q -O "$2" "$1" || die "download failed: $1"
    else
        die "curl or wget is needed to download the helper"
    fi
}

sha256_of() {
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$1" | awk '{print $1}'
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$1" | awk '{print $1}'
    else
        die "sha256sum is needed to check the download"
    fi
}

uninstall() {
    if [ -x "$BIN" ]; then
        "$BIN" service uninstall </dev/null || say "Could not remove the service; run: systemctl --user disable --now obsbot.service"
        rm -f "$BIN"
        say "Removed $BIN."
    else
        say "Nothing to remove: $BIN does not exist."
    fi
    say "Your profiles in ~/.config/obsbot are kept. Delete that folder if you do not want them."
}

install_helper() {
    [ "$(uname -s)" = "Linux" ] || die "Linux only. This system is $(uname -s)."
    case "$(uname -m)" in
        x86_64 | amd64) arch="x86_64" ;;
        aarch64 | arm64) arch="aarch64" ;;
        *) die "unsupported CPU $(uname -m): only x86_64 and aarch64 are built" ;;
    esac
    asset="obsbot-linux-$arch"

    tmp="$(mktemp -d)" || die "cannot create a temporary folder"
    trap 'rm -rf "$tmp"' EXIT INT TERM

    say "Downloading $asset ..."
    fetch "$BASE/SHA256SUMS" "$tmp/SHA256SUMS"
    fetch "$BASE/$asset" "$tmp/$asset"

    want="$(awk -v f="$asset" '$2 == f || $2 == "*" f { print $1; exit }' "$tmp/SHA256SUMS")"
    [ -n "$want" ] || die "SHA256SUMS has no entry for $asset"
    got="$(sha256_of "$tmp/$asset")"
    [ "$got" = "$want" ] || die "checksum mismatch for $asset (expected $want, got $got). Nothing was installed."
    say "Checksum OK."

    mkdir -p "$BIN_DIR"
    chmod 0755 "$tmp/$asset"
    mv -f "$tmp/$asset" "$BIN.new"
    mv -f "$BIN.new" "$BIN"
    say "Installed $BIN."

    if ! command -v systemctl >/dev/null 2>&1; then
        say "No systemd here, so the helper does not start by itself. Start it with: $BIN serve"
        exit 1
    fi
    "$BIN" service install </dev/null || {
        say "The helper is installed, but its service did not start. Start it by hand with: $BIN serve"
        exit 1
    }

    case ":$PATH:" in
        *":$BIN_DIR:"*) ;;
        *)
            say ""
            say "Note: $BIN_DIR is not in your PATH, so the 'obsbot' command is not found yet."
            say "The service works anyway. To use the command, add this line to ~/.profile and log in again:"
            say "  export PATH=\"\$HOME/.local/bin:\$PATH\""
            ;;
    esac

    say ""
    say "Done. The helper runs on http://127.0.0.1:8737 and starts at every login."
    say "Open $PAGE"
    say "Remove it again with: curl -fsSL ${PAGE}install.sh | sh -s -- --uninstall"
}

[ "$(id -u)" -ne 0 ] || die "do not run this as root or with sudo: it installs for your user only"

case "${1:-}" in
    "") install_helper ;;
    --uninstall) uninstall ;;
    -h | --help) usage ;;
    *) usage >&2; exit 2 ;;
esac
