# shellcheck shell=bash
# Shared helpers for the dotfiles install scripts.
#
# This file is sourced, not executed: use it from a script that has already run
# `set -euo pipefail`. The caller sets DRY_RUN (1 reports commands without
# running them) before calling these helpers and may set PLATFORM and MANAGER;
# the helpers never detect either. SUDO defaults to empty and is set to "sudo"
# by the caller when the native package manager needs root. Sourcing this file
# runs no commands and prints nothing; it only fills in the two defaults below,
# which keeps it safe under `set -u`.

: "${DRY_RUN:=0}"
# Set to "sudo" only when apt-get/dnf need root; brew never uses it.
: "${SUDO:=}"

run_privileged() {
  if [[ -n "$SUDO" ]]; then
    "$SUDO" "$@"
  else
    "$@"
  fi
}

print_command() {
  if [[ -n "$SUDO" ]]; then
    printf '%s %s' "$SUDO" "$*"
  else
    printf '%s' "$*"
  fi
}

# Print a step as "would run" in a dry run and "running" otherwise.
announce_step() {
  if [[ $DRY_RUN -eq 1 ]]; then
    printf 'would run: %s\n' "$1"
  else
    printf 'running: %s\n' "$1"
  fi
}

# Announce and run a privileged command, or only announce it in a dry run.
run_step() {
  local description=$1
  shift
  announce_step "$description"
  [[ $DRY_RUN -eq 1 ]] || run_privileged "$@"
}

# Same checksum tool selection as bootstrap.sh: GNU coreutils, then the
# shasum that ships with macOS.
sha256_of() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  else
    shasum -a 256 "$1" | awk '{print $1}'
  fi
}

# --- install user -----------------------------------------------------------
# The installer writes into $HOME and the XDG directories, so it must run as
# the user who owns them. `sudo` keeps the caller's HOME and `su` without `-`
# keeps the caller's environment, either of which points the installer at
# another user's home.

# Print the numeric owner uid of a path. GNU stat and BSD/macOS stat take
# different flags, so try GNU first and fall back to the BSD form. A missing
# path or a failing stat returns non-zero.
path_owner_uid() {
  local path=$1 uid
  if [[ ! -e "$path" && ! -L "$path" ]]; then
    return 1
  fi
  if uid=$(stat -c %u "$path" 2>/dev/null); then
    case "$uid" in
      ''|*[!0-9]*) ;;
      *)
        printf '%s\n' "$uid"
        return 0
        ;;
    esac
  fi
  if uid=$(stat -f %u "$path" 2>/dev/null); then
    case "$uid" in
      ''|*[!0-9]*) ;;
      *)
        printf '%s\n' "$uid"
        return 0
        ;;
    esac
  fi
  return 1
}

# Exit when $HOME or a set XDG directory exists but is owned by another uid.
# A repository root owned by another uid is only a warning: the install still
# works, but git commands run inside it (git lfs install) may not.
check_install_user() {
  local repo_root=${1:-} current_uid path uid var
  current_uid=$(id -u)

  for var in HOME XDG_CONFIG_HOME XDG_DATA_HOME; do
    case "$var" in
      HOME) path=${HOME:-} ;;
      XDG_CONFIG_HOME) path=${XDG_CONFIG_HOME:-} ;;
      XDG_DATA_HOME) path=${XDG_DATA_HOME:-} ;;
    esac
    [[ -n "$path" ]] || continue
    if ! uid=$(path_owner_uid "$path"); then
      continue
    fi
    if [[ "$uid" != "$current_uid" ]]; then
      cat >&2 <<EOF
error: \$$var ($path) is owned by uid $uid but this script runs as uid $current_uid.
       The installer writes into \$HOME, so it must run as the user who owns these
       paths. Do not use sudo or su from another account: \`sudo\` keeps the caller's
       HOME and \`su\` without \`-\` keeps the caller's environment, which points the
       installer at another user's home.
EOF
      exit 1
    fi
  done

  if [[ -n "$repo_root" ]] && uid=$(path_owner_uid "$repo_root"); then
    if [[ "$uid" != "$current_uid" ]]; then
      printf 'warning: %s is owned by uid %s; git commands in it (git lfs install) may fail for uid %s\n' \
        "$repo_root" "$uid" "$current_uid" >&2
    fi
  fi
  return 0
}
