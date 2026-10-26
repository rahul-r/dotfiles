#!/usr/bin/env bash
# Fetch the pinned plugin assets:
#   - zsh-syntax-highlighting and zsh-autosuggestions at pinned revisions
#   - TPM (tmux plugin manager)
#   - zellij wasm plugins
# Package installation is out of scope; see README.md.
#
# Usage: scripts/bootstrap.sh [--dry-run]
set -euo pipefail

DRY_RUN=0
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=1
elif [[ -n "${1:-}" ]]; then
  echo "usage: $0 [--dry-run]" >&2
  exit 2
fi

run() {
  if [[ $DRY_RUN -eq 1 ]]; then
    printf '+'
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}

# Clone a repository once, then keep it at the pinned revision.
clone_pinned() {
  local url=$1 rev=$2 dest=$3
  if [[ -d "$dest/.git" ]]; then
    run git -C "$dest" fetch --quiet origin
    run git -C "$dest" checkout --quiet "$rev"
  elif [[ -e "$dest" ]]; then
    echo "warning: $dest exists and is not a git clone; leaving it alone" >&2
  else
    run mkdir -p "$(dirname "$dest")"
    run git clone --quiet "$url" "$dest"
    run git -C "$dest" checkout --quiet "$rev"
  fi
}

sha256_of() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  else
    shasum -a 256 "$1" | awk '{print $1}'
  fi
}

download_pinned() {
  local url=$1 expected=$2 dest=$3
  if [[ -f "$dest" ]]; then
    if [[ "$(sha256_of "$dest")" == "$expected" ]]; then
      echo "ok: $dest"
    else
      echo "warning: $dest has an unexpected checksum; leaving it alone" >&2
    fi
    return
  fi
  if [[ $DRY_RUN -eq 1 ]]; then
    run curl --fail --location --silent --show-error --output "$dest" "$url"
    return
  fi
  run mkdir -p "$(dirname "$dest")"
  run curl --fail --location --silent --show-error --output "$dest.tmp" "$url"
  if [[ "$(sha256_of "$dest.tmp")" != "$expected" ]]; then
    rm -f "$dest.tmp"
    echo "error: checksum mismatch for $url" >&2
    exit 1
  fi
  run mv "$dest.tmp" "$dest"
  echo "ok: $dest"
}

ZSH_PLUGIN_DIR="$HOME/.config/zsh"
TMUX_PLUGIN_DIR="$HOME/.config/tmux/plugins"
ZELLIJ_PLUGIN_DIR="$HOME/.local/share/zellij/plugins"

clone_pinned \
  https://github.com/zsh-users/zsh-syntax-highlighting.git \
  e0165eaa730dd0fa321a6a6de74f092fe87630b0 \
  "$ZSH_PLUGIN_DIR/syntax-highlighting"
clone_pinned \
  https://github.com/zsh-users/zsh-autosuggestions.git \
  c3d4e576c9c86eac62884bd47c01f6faed043fc5 \
  "$ZSH_PLUGIN_DIR/zsh-autosuggestions"

clone_pinned \
  https://github.com/tmux-plugins/tpm.git \
  master \
  "$TMUX_PLUGIN_DIR/tpm"

download_pinned \
  https://github.com/karimould/zellij-forgot/releases/download/0.3.0/zellij_forgot.wasm \
  24d4382976fa5738d21743b827c4efab715751804169b41bf598ad711de4645c \
  "$ZELLIJ_PLUGIN_DIR/zellij_forgot.wasm"
download_pinned \
  https://github.com/dj95/zjstatus/releases/download/v0.14.0/zjstatus.wasm \
  4e53e7bd2cf544ebac3173f409e40972e811d11762293ab0331a540e23f44915 \
  "$ZELLIJ_PLUGIN_DIR/zjstatus.wasm"
download_pinned \
  https://github.com/dj95/zj-docker/releases/download/v0.2.0/zj-docker.wasm \
  05b46c5a6a7f3a88809732e1fed5e8d6ebb4b558368772d8ac5ae3443a7c896a \
  "$ZELLIJ_PLUGIN_DIR/zj-docker.wasm"

if [[ $DRY_RUN -eq 0 ]] && command -v tmux >/dev/null 2>&1; then
  if [[ -x "$TMUX_PLUGIN_DIR/tpm/bin/install_plugins" ]]; then
    echo "installing tmux plugins via TPM..."
    if ! "$TMUX_PLUGIN_DIR/tpm/bin/install_plugins"; then
      echo "warning: TPM install failed; run 'prefix + I' inside tmux" >&2
    fi
  fi
elif [[ $DRY_RUN -eq 0 ]]; then
  echo "note: tmux not found; start tmux later and press prefix + I to install plugins"
fi
