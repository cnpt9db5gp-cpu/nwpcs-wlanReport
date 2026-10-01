#!/usr/bin/env bash
# wlan-report one-line installer.
#
#   curl -fsSL https://raw.githubusercontent.com/cnpt9db5gp-cpu/nwpcs-wlanReport/main/install.sh | bash
#
# Env overrides: REPO (owner/repo), BRANCH, PREFIX (install dir, default ~/.local/bin)
set -euo pipefail

REPO="${REPO:-cnpt9db5gp-cpu/nwpcs-wlanReport}"
BRANCH="${BRANCH:-main}"
PREFIX="${PREFIX:-$HOME/.local/bin}"

say() { printf '%s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

command -v python3 >/dev/null 2>&1 || die "python3 not found — install it first, then re-run."
command -v curl >/dev/null 2>&1 || command -v wget >/dev/null 2>&1 || die "need curl or wget to download."

mkdir -p "$PREFIX"
URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}/wlan-report"
TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

if command -v curl >/dev/null 2>&1; then
  curl -fsSL "$URL" -o "$TMP" || die "download failed: $URL"
else
  wget -qO "$TMP" "$URL" || die "download failed: $URL"
fi

head -c 100 "$TMP" | grep -q "wlan-report" || die "downloaded file doesn't look like wlan-report."
install -m755 "$TMP" "$PREFIX/wlan-report"
say "installed: $PREFIX/wlan-report"

case ":$PATH:" in
  *":$PREFIX:"*) ;;
  *) say "NOTE: $PREFIX is not on your PATH. Add this to ~/.bashrc and restart your shell:"; say "  export PATH=\"\$HOME/.local/bin:\$PATH\"";;
esac

say "--- dependency check ---"
"$PREFIX/wlan-report" check-deps --no-banner || say "(optional items above can be installed later)"
say "done. try: wlan-report scan"
