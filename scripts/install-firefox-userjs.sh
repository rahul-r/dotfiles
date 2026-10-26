#!/usr/bin/env bash
# Deploy firefox/user.js into the default Firefox profile.
# Skips with a note when no Firefox installation is found (firefox,
# firefox-esr or /Applications/Firefox.app); an explicit FIREFOX_PROFILE_DIR
# overrides both that check and the profile selection.
# Probes profiles.ini; falls back to a *.default-release directory.
# Set FIREFOX_PROFILE_DIR to override the profile selection.
set -euo pipefail

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SOURCE="$REPO_ROOT/firefox/user.js"
FIREFOX_DIR="${FIREFOX_DIR:-$HOME/.mozilla/firefox}"

if [[ -z "${FIREFOX_PROFILE_DIR:-}" ]] \
  && ! command -v firefox >/dev/null 2>&1 \
  && ! command -v firefox-esr >/dev/null 2>&1 \
  && [[ ! -e /Applications/Firefox.app ]]; then
  echo "note: Firefox is not installed; skipping user.js"
  exit 0
fi

if [[ ! -f "$SOURCE" ]]; then
  echo "error: $SOURCE not found" >&2
  exit 1
fi

if [[ -n "${FIREFOX_PROFILE_DIR:-}" ]]; then
  profile_dir="$FIREFOX_PROFILE_DIR"
elif [[ -f "$FIREFOX_DIR/profiles.ini" ]]; then
  profile_path=$(awk -F= '
    /^\[/ {
      if (in_profile && is_default && path != "") { print path; done = 1; exit }
      in_profile = 0; is_default = 0; path = ""
    }
    /^\[Profile/ { in_profile = 1 }
    /^Default=1/ { is_default = 1 }
    /^Path=/ { path = $2 }
    END { if (!done && in_profile && is_default && path != "") print path }
  ' "$FIREFOX_DIR/profiles.ini")
  if [[ -z "$profile_path" ]]; then
    echo "error: no Default=1 profile found in $FIREFOX_DIR/profiles.ini" >&2
    exit 1
  fi
  profile_dir="$FIREFOX_DIR/$profile_path"
else
  profile_dir=$(find "$FIREFOX_DIR" -maxdepth 1 -type d -name '*.default-release' -print -quit 2>/dev/null || true)
fi

if [[ -z "${profile_dir:-}" || ! -d "$profile_dir" ]]; then
  echo "error: no Firefox profile found under $FIREFOX_DIR (start Firefox once first)" >&2
  exit 1
fi

if [[ -f "$profile_dir/user.js" ]] && ! cmp -s "$SOURCE" "$profile_dir/user.js"; then
  cp -p "$profile_dir/user.js" "$profile_dir/user.js.bak"
  echo "backed up existing user.js to $profile_dir/user.js.bak"
fi

install -m 644 "$SOURCE" "$profile_dir/user.js"
echo "installed $SOURCE -> $profile_dir/user.js"
