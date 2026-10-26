#!/usr/bin/env bash
# Install the applications these dotfiles expect with the native package manager.
# Usage: scripts/install-packages.sh [--dry-run]
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=SCRIPTDIR/lib/common.sh
. "$SCRIPT_DIR/lib/common.sh"

# Packages with the same name on every platform live in COMMON; each manager
# adds only what differs. Debian calls Node.js nodejs and the fd binary fd-find,
# needs npm and build-essential, and names ExifTool libimage-exiftool-perl;
# Fedora ships the compose helper as python3-podman-compose, the extra clang
# tools as clang-tools-extra and ExifTool as perl-Image-ExifTool; Homebrew uses
# node, fd, python@3.12 and exiftool, and installs the GUI applications as
# casks. man, binutils, zip/unzip and file ship with macOS, so they are listed
# only for Linux. Each list is installed as a batch; names a manager does not
# know are retried individually.
COMMON_PACKAGES=(
  git git-lfs git-delta tmux zsh curl
  fzf zoxide bat direnv chafa ranger
  podman htop eza duf neovim cppcheck ripgrep
  tree starship lazygit helix zellij pipx
)

APT_PACKAGES=(
  "${COMMON_PACKAGES[@]}"
  nodejs npm podman-compose fd-find clang-tools xsel
  btrfs-assistant
  build-essential file xdg-utils zip unzip man-db binutils fontconfig poppler-utils
  libimage-exiftool-perl
  # yazi's preview helpers. Debian 12 and Ubuntu 24.04 ship ImageMagick 6, so
  # there is no `magick` binary and font/HEIC preview is degraded there.
  ffmpeg 7zip jq imagemagick
)

DNF_PACKAGES=(
  "${COMMON_PACKAGES[@]}"
  nodejs python3-podman-compose fd-find clang-tools-extra xsel
  btrfs-assistant
  gcc gcc-c++ make file xdg-utils zip unzip man-db binutils fontconfig poppler-utils
  perl-Image-ExifTool
  # yazi's preview helpers.
  ffmpeg-free 7zip jq ImageMagick
)

BREW_FORMULAS=(
  "${COMMON_PACKAGES[@]}"
  node podman-compose fd python@3.12 llvm qemu coreutils
  # The upstream README prefers the jesseduffield/lazydocker/lazydocker tap for
  # more frequent updates; this uses the core formula.
  exiftool lsix neovide lazydocker
  # yazi and its preview helpers; `file` ships with macOS.
  yazi poppler ffmpeg sevenzip jq imagemagick
)

# Firefox is expected from the distribution or Homebrew and is not installed here.
BREW_CASKS=(
  wezterm
  font-droid-sans-mono-nerd-font font-ubuntu-mono-nerd-font
)

# Deliberately not installed on Linux: the Hyprland desktop and tools that have
# no distribution package. One line per group, printed as a closing note.
# Everything the macOS lists need comes from Homebrew, so macOS has no such note.
MANUAL_LINUX=(
  "hyprland waybar swaybg rofi grimblast - Hyprland desktop; COPR on Fedora, backports on Debian 13, grimblast from hyprwm/contrib"
  "neovide lsix - not in the Linux repositories; use upstream releases or the project script"
)

DRY_RUN=0
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    -h|--help)
      sed -n '2,3p' "$0"
      exit 0
      ;;
    *)
      echo "usage: $0 [--dry-run]" >&2
      exit 2
      ;;
  esac
done

PLATFORM=$(uname -s)
MANAGER=""
DISTRO=""

# Failures from the per-package retries, printed once at the end.
FAILURES=()

detect_platform() {
  case "$PLATFORM" in
    Darwin)
      MANAGER="brew"
      ;;
    Linux)
      local distro_like match
      if [[ -r /etc/os-release ]]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        DISTRO=$(printf '%s' "${ID:-}" | tr '[:upper:]' '[:lower:]')
        distro_like=${ID_LIKE:-}
        match=$(printf '%s %s' "${ID:-}" "$distro_like" | tr '[:upper:]' '[:lower:]')
      else
        DISTRO=""
        match=""
      fi
      case "$match" in
        *ubuntu*|*debian*) MANAGER="apt-get" ;;
        *fedora*) MANAGER="dnf" ;;
        *)
          echo "error: unsupported Linux distribution '${DISTRO:-unknown}': install the packages manually" >&2
          exit 1
          ;;
      esac
      ;;
    *)
      echo "error: unsupported platform '$PLATFORM'" >&2
      exit 1
      ;;
  esac
}

platform_label() {
  case "$MANAGER" in
    apt-get) printf 'Linux (%s; apt-get)' "$DISTRO" ;;
    dnf) printf 'Linux (%s; dnf)' "$DISTRO" ;;
    *) printf 'macOS (brew)' ;;
  esac
}

configure_sudo() {
  if [[ "$MANAGER" != "brew" && $EUID -ne 0 ]]; then
    if ! command -v sudo >/dev/null 2>&1; then
      echo "error: sudo is required to install packages with $MANAGER and is not available" >&2
      exit 1
    fi
    SUDO="sudo"
  fi
}

# On Debian/Ubuntu two binaries are renamed to avoid collisions: bat becomes
# batcat and fd becomes fdfind. The shell configuration tests `command -v bat`
# and `command -v fd`, so link the real binaries into ~/.local/bin. Existing
# paths there are never replaced.
link_renamed_binary() {
  local source_name=$1 target_name=$2 source_path target
  if ! source_path=$(command -v "$source_name" 2>/dev/null); then
    return 0
  fi
  if command -v "$target_name" >/dev/null 2>&1; then
    return 0
  fi
  target="$HOME/.local/bin/$target_name"
  if [[ -e "$target" || -L "$target" ]]; then
    if [[ $DRY_RUN -eq 1 ]]; then
      echo "would skip: $target already exists"
    else
      echo "skip: $target already exists"
    fi
    return 0
  fi
  if [[ $DRY_RUN -eq 1 ]]; then
    echo "would link: $target -> $source_path"
    return 0
  fi
  mkdir -p "$HOME/.local/bin"
  ln -s "$source_path" "$target"
  echo "linked: $target -> $source_path"
}

fix_debian_binary_names() {
  if [[ "$MANAGER" != "apt-get" ]]; then
    return 0
  fi
  link_renamed_binary batcat bat
  link_renamed_binary fdfind fd
}

install_batch() {
  # usage: install_batch <label> <command...> :: <item>...
  local label=$1
  shift
  local -a cmd_args=()
  local -a items=()
  local item

  while [[ $# -gt 0 && "$1" != "::" ]]; do
    cmd_args+=("$1")
    shift
  done
  shift
  while [[ $# -gt 0 ]]; do
    items+=("$1")
    shift
  done

  printf 'running: %s\n' "$(print_command "${cmd_args[@]}" "${items[@]}")"
  if run_privileged "${cmd_args[@]}" "${items[@]}"; then
    return 0
  fi

  echo "warning: batch install of $label failed; retrying one at a time" >&2
  for item in "${items[@]}"; do
    printf 'retrying: %s\n' "$(print_command "${cmd_args[@]}" "$item")"
    if ! run_privileged "${cmd_args[@]}" "$item"; then
      FAILURES+=("$item")
    fi
  done
}

# Run the extra application installers in install-packages.d in filename order.
# That order is lexicographic, so the numeric prefix is zero-padded to three
# digits: a later four-digit prefix still sorts after the three-digit ones
# (010 before 100). Each fragment is sourced and must define exactly one entry
# point named after its file: install_<basename without numeric prefix, dashes
# as underscores>, so 030-nerd-fonts.sh defines install_nerd_fonts. Fragments
# only define functions and constants and record their own failures in
# FAILURES.
install_extra_apps() {
  local fragment name
  for fragment in "$SCRIPT_DIR"/install-packages.d/*.sh; do
    [ -e "$fragment" ] || continue
    # shellcheck disable=SC1090,SC1091
    . "$fragment"
    name=$(basename "$fragment" .sh)   # 010-wezterm
    name=${name#*-}                    # wezterm
    name=${name//-/_}                  # nerd_fonts
    if ! declare -F "install_$name" >/dev/null; then
      echo "error: $fragment does not define install_$name" >&2
      FAILURES+=("${fragment##*/}")
      continue
    fi
    "install_$name"
  done
}

# The git-lfs package only ships the binary; the filters and per-repository
# hooks are registered by this one-time command. It writes the user's git
# config, not the system one, so it never needs sudo.
configure_git_lfs() {
  if ! command -v git >/dev/null 2>&1 || ! git lfs version >/dev/null 2>&1; then
    echo "note: git-lfs is not available; skipping 'git lfs install'"
    return 0
  fi
  announce_step "git lfs install"
  if [[ $DRY_RUN -eq 1 ]]; then
    return 0
  fi
  if ! git lfs install; then
    echo "error: 'git lfs install' failed" >&2
    FAILURES+=("git-lfs")
  fi
}

print_manual_note() {
  if [[ "$MANAGER" == "brew" ]]; then
    return 0
  fi
  echo
  echo "not installed by this script:"
  local entry
  for entry in "${MANUAL_LINUX[@]}"; do
    printf '  %s\n' "$entry"
  done
}

detect_platform
configure_sudo

if [[ $DRY_RUN -eq 1 ]]; then
  echo "platform: $(platform_label)"
  case "$MANAGER" in
    apt-get)
      printf 'would run: %s\n' "$(print_command apt-get update)"
      printf 'would run: %s\n' "$(print_command apt-get install -y "${APT_PACKAGES[@]}")"
      ;;
    dnf)
      printf 'would run: %s\n' "$(print_command dnf install -y "${DNF_PACKAGES[@]}")"
      ;;
    brew)
      printf 'would run: %s\n' "$(print_command brew install "${BREW_FORMULAS[@]}")"
      printf 'would run: %s\n' "$(print_command brew install --cask "${BREW_CASKS[@]}")"
      ;;
  esac
  install_extra_apps
  configure_git_lfs
  fix_debian_binary_names
  print_manual_note
  exit 0
fi

echo "platform: $(platform_label)"
case "$MANAGER" in
  apt-get)
    printf 'running: %s\n' "$(print_command apt-get update)"
    run_privileged apt-get update
    install_batch "packages" apt-get install -y :: "${APT_PACKAGES[@]}"
    ;;
  dnf)
    install_batch "packages" dnf install -y :: "${DNF_PACKAGES[@]}"
    ;;
  brew)
    install_batch "packages" brew install :: "${BREW_FORMULAS[@]}"
    install_batch "casks" brew install --cask :: "${BREW_CASKS[@]}"
    ;;
esac

install_extra_apps
configure_git_lfs
fix_debian_binary_names
print_manual_note

if [[ ${#FAILURES[@]} -gt 0 ]]; then
  echo "could not install: ${FAILURES[*]}" >&2
  exit 1
fi
