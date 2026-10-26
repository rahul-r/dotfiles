#!/usr/bin/env bash
# Install the dotfiles with GNU Stow.
# Usage: scripts/install.sh [--dry-run] [--no-bootstrap] [--backup-conflicts]
set -euo pipefail

DRY_RUN=0
BOOTSTRAP=1
BACKUP_CONFLICTS=0
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --no-bootstrap) BOOTSTRAP=0 ;;
    --backup-conflicts) BACKUP_CONFLICTS=1 ;;
    -h|--help)
      sed -n '2,3p' "$0"
      exit 0
      ;;
    *)
      echo "usage: $0 [--dry-run] [--no-bootstrap] [--backup-conflicts]" >&2
      exit 2
      ;;
  esac
done

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
STOW_DIR="$REPO_ROOT/stow"

# Shared helpers (SUDO default, run_privileged, print_command, announce_step,
# run_step, sha256_of). The prerequisite installer below keeps its own
# platform detection and sudo decision.
# shellcheck source=SCRIPTDIR/lib/common.sh
. "$REPO_ROOT/scripts/lib/common.sh"

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

# Packages to stow. Hyprland is only relevant on a native Linux desktop, not on
# WSL. This list is also used by the conflict preflight below.
packages=(home zsh git editor terminals)
case "$(uname -s)" in
  Linux)
    if ! grep -qi microsoft /proc/version 2>/dev/null; then
      packages+=(hyprland)
    fi
    ;;
esac

# --- conflict preflight -----------------------------------------------------
# Stow refuses to overwrite existing paths. List every conflict for the
# selected packages up front, before anything in $HOME is touched, so one run
# shows all of them. A target reached through a folded stow directory or
# through a symlink into the stow tree is already stow-owned and is not a
# conflict.

conflicts=()
conflict_reasons=()

# Collapse `.` and `..` components without touching the filesystem. Used only
# for a dangling symlink whose parent chain does not exist, where `cd -P`
# cannot produce a physical path.
normalize_path() {
  local rest out part
  rest=$1
  out=""
  while [[ -n "$rest" ]]; do
    part=${rest%%/*}
    case "$part" in
      ''|.) ;;
      ..) out=${out%/*} ;;
      *) out="$out/$part" ;;
    esac
    if [[ "$rest" == */* ]]; then
      rest=${rest#*/}
    else
      rest=""
    fi
  done
  printf '%s\n' "${out:-/}"
}

# Print a symlink chain's endpoint without `readlink -f` (unavailable on
# macOS). Relative link targets are resolved against the link's directory, and
# the endpoint's parent is made physical when it exists so paths containing
# `..` can be compared with $STOW_REAL.
resolve_link_target() {
  local path hops link_target parent
  path=$1
  hops=0
  while [[ -L "$path" ]]; do
    hops=$((hops + 1))
    if [[ $hops -gt 40 ]]; then
      break
    fi
    link_target=$(readlink "$path") || break
    case "$link_target" in
      /*) path=$link_target ;;
      *) path="$(dirname "$path")/$link_target" ;;
    esac
  done
  if [[ -d "$(dirname "$path")" ]]; then
    parent=$(cd -P "$(dirname "$path")" && pwd -P)
    path="$parent/$(basename "$path")"
  else
    path=$(normalize_path "$path")
  fi
  printf '%s\n' "$path"
}

scan_conflicts() {
  local pkg file rel target parent_real resolved reason
  conflicts=()
  conflict_reasons=()
  STOW_REAL=$(cd "$STOW_DIR" && pwd -P)

  for pkg in "${packages[@]}"; do
    if [[ ! -d "$STOW_DIR/$pkg" ]]; then
      continue
    fi
    while IFS= read -r -d '' file; do
      rel=${file#"$STOW_DIR/$pkg/"}
      if [[ "$rel" == ".stow-local-ignore" ]]; then
        continue
      fi

      target="$HOME/$rel"
      if [[ ! -d "$(dirname "$target")" ]]; then
        continue
      fi

      parent_real=$(cd -P "$(dirname "$target")" && pwd -P)
      case "$parent_real" in
        "$STOW_REAL"/*) continue ;;
      esac

      if [[ -L "$target" ]]; then
        resolved=$(resolve_link_target "$target")
        case "$resolved" in
          "$STOW_REAL"/*) continue ;;
        esac
        reason="symlink to elsewhere"
      elif [[ -d "$target" ]]; then
        reason="existing directory"
      elif [[ -e "$target" ]]; then
        reason="existing file"
      else
        continue
      fi

      conflicts+=("$target")
      conflict_reasons+=("$reason")
    done < <(find "$STOW_DIR/$pkg" -type f -print0)
  done
}

report_conflicts() {
  local i
  for ((i = 0; i < ${#conflicts[@]}; i++)); do
    printf 'conflict: %s (%s)\n' "${conflicts[$i]}" "${conflict_reasons[$i]}"
  done
  printf '\n'
}

print_conflict_moves() {
  local i target rel
  for ((i = 0; i < ${#conflicts[@]}; i++)); do
    target=${conflicts[$i]}
    rel=${target#"$HOME"/}
    printf 'mv -v -- %q %q\n' "$target" "$HOME/dotfile-backup/$rel"
  done
}

handle_conflicts() {
  local i target rel dest dest_base suffix n
  report_conflicts

  if [[ $DRY_RUN -eq 1 ]]; then
    print_conflict_moves
    printf '\n'
    if [[ $BACKUP_CONFLICTS -eq 1 ]]; then
      echo "dry run: no paths were moved; a real run would move them to $HOME/dotfile-backup and continue"
    else
      echo "dry run: no paths were moved; a real run would abort"
    fi
    exit 0
  fi

  if [[ $BACKUP_CONFLICTS -eq 0 ]]; then
    echo "Nothing was changed; GNU Stow will not overwrite these paths."
    echo "Move them aside and re-run, or re-run with --backup-conflicts to move them to ~/dotfile-backup:"
    print_conflict_moves
    exit 1
  fi

  echo "backing up conflicting paths to $HOME/dotfile-backup"
  mkdir -p "$HOME/dotfile-backup"
  for ((i = 0; i < ${#conflicts[@]}; i++)); do
    target=${conflicts[$i]}
    rel=${target#"$HOME"/}
    dest_base="$HOME/dotfile-backup/$rel"
    dest=$dest_base
    if [[ -e "$dest" || -L "$dest" ]]; then
      suffix=$(date +%Y%m%d-%H%M%S)
      dest="$dest_base.$suffix"
      n=1
      while [[ -e "$dest" || -L "$dest" ]]; do
        dest="$dest_base.$suffix-$n"
        n=$((n + 1))
      done
    fi
    mkdir -p "$(dirname "$dest")"
    mv -v -- "$target" "$dest"
  done
}

scan_conflicts
if [[ ${#conflicts[@]} -gt 0 ]]; then
  handle_conflicts
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
