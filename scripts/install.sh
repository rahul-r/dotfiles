#!/usr/bin/env bash
# Install the dotfiles with GNU Stow.
# Usage: scripts/install.sh [--dry-run] [--no-bootstrap]
set -euo pipefail

DRY_RUN=0
BOOTSTRAP=1
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --no-bootstrap) BOOTSTRAP=0 ;;
    -h|--help)
      sed -n '2,3p' "$0"
      exit 0
      ;;
    *)
      echo "usage: $0 [--dry-run] [--no-bootstrap]" >&2
      exit 2
      ;;
  esac
done

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
STOW_DIR="$REPO_ROOT/stow"

# Set to "sudo" only when the prerequisite installer needs root for apt-get/dnf.
SUDO=""

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

# Install stow, git and curl when they are missing. On platforms this script
# does not know how to handle, exit only when something is actually missing.
ensure_prerequisites() {
  local cmd
  local missing=()

  for cmd in stow git curl; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      missing+=("$cmd")
    fi
  done

  if [[ ${#missing[@]} -eq 0 ]]; then
    return 0
  fi

  local platform distro distro_lc manager install_args
  platform=$(uname -s)

  case "$platform" in
    Darwin)
      if ! command -v brew >/dev/null 2>&1; then
        echo "error: missing prerequisites: ${missing[*]}; Homebrew is required to install them on macOS (see https://brew.sh)" >&2
        exit 1
      fi
      manager="brew"
      ;;
    Linux)
      distro=$(
        if [[ -r /etc/os-release ]]; then
          # shellcheck disable=SC1091
          . /etc/os-release
          printf '%s' "${ID:-}"
          if [[ -n "${ID_LIKE:-}" ]]; then
            printf ' %s' "$ID_LIKE"
          fi
        fi
      )
      distro_lc=$(printf '%s' "$distro" | tr '[:upper:]' '[:lower:]')
      case "$distro_lc" in
        *ubuntu*|*debian*)
          manager="apt-get"
          ;;
        *fedora*)
          manager="dnf"
          ;;
        *)
          echo "error: unsupported Linux distribution '${distro:-unknown}': missing prerequisites: ${missing[*]}; install them manually (see README.md)" >&2
          exit 1
          ;;
      esac
      ;;
    *)
      echo "error: unsupported platform '$platform': missing prerequisites: ${missing[*]}; install them manually (see README.md)" >&2
      exit 1
      ;;
  esac

  if [[ "$manager" != "brew" && $EUID -ne 0 ]]; then
    if ! command -v sudo >/dev/null 2>&1; then
      echo "error: missing prerequisites: ${missing[*]}; sudo is required to install them with $manager and is not available" >&2
      exit 1
    fi
    SUDO="sudo"
  fi

  install_args=(install)
  if [[ "$manager" != "brew" ]]; then
    install_args+=(-y)
  fi

  if [[ $DRY_RUN -eq 1 ]]; then
    echo "missing prerequisites: ${missing[*]} (would use $manager)"
    if [[ "$manager" == "apt-get" ]]; then
      printf 'would run: %s\n' "$(print_command apt-get update)"
    fi
    printf 'would install: %s\n' "$(print_command "$manager" "${install_args[@]}" "${missing[@]}")"
    return 0
  fi

  echo "installing missing prerequisites: ${missing[*]} (using $manager)"
  if [[ "$manager" == "apt-get" ]]; then
    printf 'running: %s\n' "$(print_command apt-get update)"
    run_privileged apt-get update
  fi
  printf 'running: %s\n' "$(print_command "$manager" "${install_args[@]}" "${missing[@]}")"
  run_privileged "$manager" "${install_args[@]}" "${missing[@]}"

  local still_missing=()
  for cmd in "${missing[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      still_missing+=("$cmd")
    fi
  done
  if [[ ${#still_missing[@]} -ne 0 ]]; then
    echo "error: prerequisites still missing after install: ${still_missing[*]}" >&2
    exit 1
  fi
}

ensure_prerequisites

if ! command -v stow >/dev/null 2>&1; then
  echo "error: GNU Stow is not installed; re-run without --dry-run to install it, or install it manually (see README.md)" >&2
  exit 1
fi

if [[ ! -d "$STOW_DIR" ]]; then
  echo "error: $STOW_DIR not found" >&2
  exit 1
fi

# Keep these directories real so that bootstrap can clone into them; otherwise
# Stow would fold the whole directory into a symlink.
dirs=(
  "$HOME/.config/zsh"
  "$HOME/.config/tmux"
  "$HOME/.local/bin"
  "$HOME/.local/share/zellij/plugins"
  "$HOME/.vim/undo"
)
if [[ $DRY_RUN -eq 1 ]]; then
  printf 'would create: %s\n' "${dirs[*]}"
else
  mkdir -p "${dirs[@]}"
fi

packages=(home zsh git editor terminals lf)
case "$(uname -s)" in
  Linux)
    # Hyprland is only relevant on a native Linux desktop, not on WSL.
    if ! grep -qi microsoft /proc/version 2>/dev/null; then
      packages+=(hyprland)
    fi
    ;;
esac

stow_args=(--restow --dir "$STOW_DIR" --target "$HOME" --verbose=1)
if [[ $DRY_RUN -eq 1 ]]; then
  stow_args+=(--no)
  echo "dry run: no files will be changed"
fi

echo "stowing: ${packages[*]}"
stow "${stow_args[@]}" "${packages[@]}"

if [[ $DRY_RUN -eq 0 ]]; then
  if [[ $BOOTSTRAP -eq 1 ]]; then
    "$REPO_ROOT/scripts/bootstrap.sh"
  else
    echo "skipped bootstrap; run scripts/bootstrap.sh later"
  fi

  if [[ -d "$HOME/.mozilla/firefox" ]]; then
    "$REPO_ROOT/scripts/install-firefox-userjs.sh"
  else
    echo "note: Firefox profile directory not found; skipping user.js (see README.md)"
  fi
fi

cat <<'EOF'

Next steps:
  - open a new shell (or re-source ~/.profile and ~/.config/zsh/.zshrc)
  - tmux: press prefix + I if the plugins were not installed automatically
  - Firefox: install uBlock Origin and Bitwarden manually
  - first nvim start downloads LazyVim plugins
  - fonts and remaining setup steps: see README.md
EOF
