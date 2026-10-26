#!/usr/bin/env bash
# Remove the Stow symlinks.
# Usage: scripts/uninstall.sh [--apply]
# Without --apply this only prints and dry-runs the stow command.
set -euo pipefail

APPLY=0
for arg in "$@"; do
  case "$arg" in
    --apply) APPLY=1 ;;
    -h|--help)
      sed -n '2,4p' "$0"
      exit 0
      ;;
    *)
      echo "usage: $0 [--apply]" >&2
      exit 2
      ;;
  esac
done

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
STOW_DIR="$REPO_ROOT/stow"

if ! command -v stow >/dev/null 2>&1; then
  echo "error: GNU Stow is not installed" >&2
  exit 1
fi

packages=(home zsh git editor terminals lf)
case "$(uname -s)" in
  Linux)
    if ! grep -qi microsoft /proc/version 2>/dev/null; then
      packages+=(hyprland)
    fi
    ;;
esac

stow_args=(--delete --dir "$STOW_DIR" --target "$HOME" --verbose=1)

if [[ $APPLY -eq 0 ]]; then
  echo "Dry run only. Re-run with --apply to remove these links:"
  echo "  stow --delete --dir $STOW_DIR --target $HOME ${packages[*]}"
  stow "${stow_args[@]}" --no "${packages[@]}"
  exit 0
fi

stow "${stow_args[@]}" "${packages[@]}"

cat <<'EOF'

Stow links removed.
Left in place (remove manually only if you no longer want them):
  ~/.config/zsh/syntax-highlighting
  ~/.config/zsh/zsh-autosuggestions
  ~/.config/tmux/plugins
  ~/.local/share/zellij/plugins
  ~/.vim/undo
  ~/.mozilla/firefox/<profile>/user.js
EOF
