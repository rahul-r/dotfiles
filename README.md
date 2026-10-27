# Dotfiles (GNU Stow)

This repository holds ordinary GNU Stow packages that deploy dotfiles into
`$HOME`, plus an install script, a bootstrap script for pinned plugin assets,
and a script that copies `firefox/user.js` into an existing Firefox profile. See
the [GNU Stow manual](https://www.gnu.org/software/stow/manual/stow.html) for
how packages, folding and ignore lists work.

Nothing here is applied automatically. The install script installs `stow`,
`git` and `curl` if they are missing (with apt-get, dnf or Homebrew), places
symlinks in `$HOME`, fetches the pinned plugin assets, and copies
`firefox/user.js` into an existing Firefox profile (skipped when Firefox is not
installed); it installs nothing else and does not edit `/etc`.

## Install

Prerequisites: `git`, `curl`, and GNU Stow. They are installed automatically on
Ubuntu/Debian, Fedora and macOS; on any other distribution or platform the
script exits with an error if any of them is missing, so install them first
there. Everything else (`zsh`, `tmux`, `neovim`, fonts, …) is installed
separately by the package script below.

```sh
git clone https://github.com/rahul-r/dotfiles ~/.dotfiles
cd ~/.dotfiles

# inspect planned links without changing or installing anything
scripts/install.sh --dry-run

scripts/install.sh
```

The applications these files expect are installed by
`scripts/install-packages.sh` (apt, dnf or Homebrew; on Debian/Ubuntu it
installs WezTerm and yazi from their upstream APT repositories, on Fedora from
COPR, and on Linux it also installs the Ubuntu Mono and Droid Sans Mono Nerd
Fonts). Its package names live in `scripts/packages.list`, one application per
line; comment a line out to skip that application. It also runs `git lfs install`
to register the Git LFS filters and hooks. It prints anything it cannot install
from the native repositories.

If you prefer to run Stow by hand, create the runtime directories first (the
install script does this), then use exactly:

```sh
mkdir -p ~/.config/zsh ~/.config/tmux ~/.local/bin \
  ~/.local/share/zellij/plugins ~/.vim/undo
cd ~/.dotfiles
stow --restow --dir stow --target "$HOME" home zsh git editor terminals hyprland
```

Without those directories Stow folds `~/.config/zsh` into one symlink, and the
bootstrap clones would be written into this repository.

The install script checks for conflicting paths before touching anything and
lists them with the exact `mv` commands. Re-run with `--backup-conflicts` to
move them to `~/dotfile-backup` and continue; `--adopt` is never used.

After installing, open a new shell, start `nvim` once (LazyVim downloads its
plugins), and use `prefix + I` in tmux if TPM did not install the plugins
automatically.

## Update

```sh
cd ~/.dotfiles
git pull
scripts/install.sh --no-bootstrap   # restows; existing config edits are kept
```

Changed untracked data (zsh history, tmux resurrect, zellij cache) is not in
this repository and is untouched. To refresh the pinned plugin assets:

```sh
scripts/bootstrap.sh
```

TPM plugins are updated inside tmux with `prefix + U`. Zellij plugin `.wasm`
files are checksum-pinned in `scripts/bootstrap.sh`; existing files with a
different checksum are left alone with a warning.

## Rollback

```sh
cd ~/.dotfiles
scripts/uninstall.sh            # dry run: prints the command and simulates it
scripts/uninstall.sh --apply    # removes the Stow symlinks
git checkout <commit>           # any earlier Stow commit, then reinstall
scripts/install.sh
```

`uninstall.sh` does not remove packages, plugin clones, or caches.

## Removal

```sh
scripts/uninstall.sh --apply
rm -rf ~/.dotfiles
```

Optionally remove the bootstrap data listed at the end of `uninstall.sh`'s
output.

## Manual steps

- **Firefox extensions**: install Firefox if your distribution does not
  provide it, then add uBlock Origin and Bitwarden from addons.mozilla.org
  once. `user.js` cannot install extensions.
- **WSL git email**: the static config contains the approved address. On WSL,
  override it once with `git config --global user.email ""`; Git reads
  `~/.gitconfig` after `~/.config/git/config`, so this wins without editing the
  stowed file. Use `git config --global user.email jossb6cw@duck.com` to set it
  back.
- **Hyprland**: install Hyprland (and `waybar`, `swaybg`, `rofi`, `grimblast`,
  `nautilus`, `flatpak` with Brave) from your distro/COPR. The session entry is
  provided by the package under `/usr/share/wayland-sessions`.
- **Neovim tooling**: `pipx` and `npm` are installed; add the language
  servers/formatters you use, e.g.
  `pipx install yamllint flake8 beautysh mdformat pynvim cmakelang` and
  `npm install -g markdownlint-cli stylelint @fsouza/prettierd eslint neovim`.
  `pynvim` must be visible to the Python interpreter Neovim uses.
