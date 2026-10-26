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
