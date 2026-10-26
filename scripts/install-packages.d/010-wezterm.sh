# shellcheck shell=bash
# Install WezTerm from its upstream repositories on Linux.

# No Linux distribution packages WezTerm, so use its upstream routes: the APT
# repository on Debian/Ubuntu and the nightly-only COPR on Fedora. macOS gets it
# from BREW_CASKS, and other distributions are covered by MANUAL_LINUX. A failed
# step is recorded in FAILURES instead of aborting the whole installation.
install_wezterm() {
  local keyring=/usr/share/keyrings/wezterm-fury.gpg
  local source_list=/etc/apt/sources.list.d/wezterm.list
  local key_url=https://apt.fury.io/wez/gpg.key
  local repo_line='deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *'
  local new_keyring=0

  if [[ "$PLATFORM" == "Darwin" ]] || command -v wezterm >/dev/null 2>&1; then
    return 0
  fi

  case "$MANAGER" in
    apt-get)
      if [[ -e "$keyring" ]]; then
        echo "already configured: $keyring"
      else
        new_keyring=1
        announce_step "curl -fsSL $key_url | $(print_command gpg --yes --dearmor -o "$keyring")"
        if [[ $DRY_RUN -eq 0 ]]; then
          if ! curl -fsSL "$key_url" | run_privileged gpg --yes --dearmor -o "$keyring"; then
            FAILURES+=("wezterm")
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
            FAILURES+=("wezterm")
            return 0
          fi
        fi
      fi
      if [[ $new_keyring -eq 1 ]] && ! run_step "$(print_command chmod 644 "$keyring")" chmod 644 "$keyring"; then
        FAILURES+=("wezterm")
        return 0
      fi
      if ! run_step "$(print_command apt-get update)" apt-get update; then
        FAILURES+=("wezterm")
        return 0
      fi
      if run_step "$(print_command apt-get install -y wezterm)" apt-get install -y wezterm; then
        [[ $DRY_RUN -eq 1 ]] || echo "installed: wezterm"
      elif run_step "$(print_command apt-get install -y wezterm-nightly)" apt-get install -y wezterm-nightly; then
        [[ $DRY_RUN -eq 1 ]] || echo "installed: wezterm (wezterm-nightly)"
      else
        FAILURES+=("wezterm")
      fi
      ;;
    dnf)
      # Fedora only has nightly builds in this COPR. Enabling it needs the
      # dnf-plugins-core copr command; if that is missing, record the failure.
      if ! run_step "$(print_command dnf copr enable -y wezfurlong/wezterm-nightly)" dnf copr enable -y wezfurlong/wezterm-nightly; then
        FAILURES+=("wezterm")
        return 0
      fi
      if ! run_step "$(print_command dnf install -y wezterm)" dnf install -y wezterm; then
        FAILURES+=("wezterm")
        return 0
      fi
      [[ $DRY_RUN -eq 1 ]] || echo "installed: wezterm (wezterm-nightly)"
      ;;
  esac
}
