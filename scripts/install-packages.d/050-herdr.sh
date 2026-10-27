# shellcheck shell=bash
# Install herdr (https://herdr.dev) with its upstream installer on Linux.

# Neither Debian/Ubuntu nor Fedora packages herdr, so use the documented
# installer from https://herdr.dev/docs/install/. It reads the release manifest
# at https://herdr.dev/latest.json and verifies the downloaded binary's SHA-256
# before installing it. The installer needs curl and awk, plus one of
# sha256sum, shasum or openssl. macOS gets herdr from Homebrew (BREW_FORMULAS).
# A failed step is recorded in FAILURES instead of aborting the installation.
install_herdr() {
  local url=https://herdr.dev/install.sh
  local bin_dir="$HOME/.local/bin"
  local tmp installer

  if [[ "$PLATFORM" == "Darwin" ]] || command -v herdr >/dev/null 2>&1; then
    return 0
  fi

  if [[ $DRY_RUN -eq 1 ]]; then
    announce_step "curl -fsSL -o <tmp>/install.sh $url"
    announce_step "cd <tmp> && HERDR_INSTALL_DIR=$bin_dir sh <tmp>/install.sh"
    return 0
  fi

  if ! mkdir -p "$bin_dir"; then
    echo "error: could not create $bin_dir" >&2
    FAILURES+=("herdr")
    return 0
  fi
  if ! tmp=$(mktemp -d); then
    echo "error: could not create a temporary directory for herdr" >&2
    FAILURES+=("herdr")
    return 0
  fi
  installer="$tmp/install.sh"

  announce_step "curl -fsSL -o $installer $url"
  if ! curl -fsSL -o "$installer" "$url"; then
    echo "error: could not download $url" >&2
    rm -rf "$tmp"
    FAILURES+=("herdr")
    return 0
  fi

  # The installer downloads the release binary into the current directory, so
  # run it from the throwaway directory and remove that afterwards.
  announce_step "cd $tmp && HERDR_INSTALL_DIR=$bin_dir sh $installer"
  if ! ( cd "$tmp" && HERDR_INSTALL_DIR="$bin_dir" sh "$installer" ); then
    echo "error: the herdr installer failed" >&2
    rm -rf "$tmp"
    FAILURES+=("herdr")
    return 0
  fi
  rm -rf "$tmp"

  if ! command -v herdr >/dev/null 2>&1 && [[ ! -x "$bin_dir/herdr" ]]; then
    echo "error: herdr is not on PATH and $bin_dir/herdr is not executable" >&2
    FAILURES+=("herdr")
    return 0
  fi
  echo "installed: herdr"
}
