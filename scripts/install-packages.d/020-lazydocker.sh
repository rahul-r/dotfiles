# shellcheck shell=bash
# Install lazydocker with its upstream installer into ~/.local/bin.

# No Linux distribution packages lazydocker, so use the automated route from
# its README. It always installs the latest upstream release into ~/.local/bin;
# a running Docker is needed at runtime, not to install.
install_lazydocker() {
  local url=https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh
  local bin_dir="$HOME/.local/bin"
  local tmp installer

  if [[ "$PLATFORM" == "Darwin" ]] || command -v lazydocker >/dev/null 2>&1; then
    return 0
  fi

  if [[ $DRY_RUN -eq 1 ]]; then
    announce_step "curl -fsSL -o <tmp>/install_update_linux.sh $url"
    announce_step "cd <tmp> && DIR=$bin_dir bash <tmp>/install_update_linux.sh"
    return 0
  fi

  if ! mkdir -p "$bin_dir"; then
    FAILURES+=("lazydocker")
    return 0
  fi
  if ! tmp=$(mktemp -d); then
    FAILURES+=("lazydocker")
    return 0
  fi
  installer="$tmp/install_update_linux.sh"

  # The installer downloads its release tarball into the current directory,
  # so run it from a throwaway directory and remove that afterwards.
  announce_step "curl -fsSL -o $installer $url"
  if ! curl -fsSL -o "$installer" "$url"; then
    rm -rf "$tmp"
    FAILURES+=("lazydocker")
    return 0
  fi

  announce_step "cd $tmp && DIR=$bin_dir bash $installer"
  if ! ( cd "$tmp" && DIR="$bin_dir" bash "$installer" ); then
    rm -rf "$tmp"
    FAILURES+=("lazydocker")
    return 0
  fi
  rm -rf "$tmp"

  if ! command -v lazydocker >/dev/null 2>&1 && [[ ! -x "$bin_dir/lazydocker" ]]; then
    FAILURES+=("lazydocker")
    return 0
  fi
  echo "installed: lazydocker"
}
