# shellcheck shell=bash
# Install yazi from its upstream repositories on Linux.

# No Linux distribution packages yazi, so use its upstream routes: the APT
# repository on Debian/Ubuntu and the third-party COPR on Fedora. macOS gets it
# from BREW_FORMULAS, so this fragment adds no repository there. A failed step
# is recorded in FAILURES instead of aborting the whole installation.
install_yazi() {
  local keyring=/usr/share/keyrings/yazi-keyring.gpg
  local source_list=/etc/apt/sources.list.d/yazi.list
  local key_url=https://yazi-rs.github.io/builds/yazi-keyring.gpg
  local repo_line='deb [signed-by=/usr/share/keyrings/yazi-keyring.gpg] https://yazi-rs.github.io/builds/ stable main'

  if [[ "$PLATFORM" == "Darwin" ]] || command -v yazi >/dev/null 2>&1; then
    return 0
  fi

  case "$MANAGER" in
    apt-get)
      # The upstream key is already a binary GPG keyring, so it is written
      # as-is; there is no `gpg --dearmor` step.
      if [[ -e "$keyring" ]]; then
        echo "already configured: $keyring"
      else
        announce_step "curl -fsSL $key_url | $(print_command tee "$keyring")"
        if [[ $DRY_RUN -eq 0 ]]; then
          if ! curl -fsSL "$key_url" | run_privileged tee "$keyring" >/dev/null; then
            FAILURES+=("yazi")
            return 0
          fi
        fi
      fi
      if [[ -e "$source_list" ]]; then
        echo "already configured: $source_list"
      else
        announce_step "echo '$repo_line' | $(print_command tee "$source_list")"
        if [[ $DRY_RUN -eq 0 ]]; then
          if ! echo "$repo_line" | run_privileged tee "$source_list" >/dev/null; then
            FAILURES+=("yazi")
            return 0
          fi
        fi
      fi
      if ! run_step "$(print_command apt-get update)" apt-get update; then
        FAILURES+=("yazi")
        return 0
      fi
      if ! run_step "$(print_command apt-get install -y yazi)" apt-get install -y yazi; then
        FAILURES+=("yazi")
        return 0
      fi
      ;;
    dnf)
      # This COPR is third-party, not maintained by the yazi project. Enabling
      # it needs the `dnf copr` command, which ships in dnf-plugins-core.
      if ! run_step "$(print_command dnf copr enable -y lihaohong/yazi)" dnf copr enable -y lihaohong/yazi; then
        if ! dnf copr --help >/dev/null 2>&1; then
          echo "error: 'dnf copr' is unavailable; install dnf-plugins-core to enable the yazi COPR" >&2
        else
          echo "error: could not enable the yazi COPR" >&2
        fi
        FAILURES+=("yazi")
        return 0
      fi
      if ! run_step "$(print_command dnf install -y yazi)" dnf install -y yazi; then
        FAILURES+=("yazi")
        return 0
      fi
      ;;
  esac

  if [[ $DRY_RUN -eq 1 ]]; then
    return 0
  fi
  # yazi needs `file` for MIME detection; it is already in the APT and DNF
  # package lists.
  if ! command -v yazi >/dev/null 2>&1; then
    echo "error: yazi is still not on PATH after installation" >&2
    FAILURES+=("yazi")
    return 0
  fi
  echo "installed: yazi"
}
