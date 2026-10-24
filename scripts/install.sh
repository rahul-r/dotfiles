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

if ! command -v stow >/dev/null 2>&1; then
  echo "error: GNU Stow is not installed (install the 'stow' package, see README.md)" >&2
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

packages=(zsh git editor tmux terminals lf)
case "$(uname -s)" in
  Darwin)
    packages+=(bin)
    ;;
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
  - fonts and remaining native packages: see README.md
EOF
