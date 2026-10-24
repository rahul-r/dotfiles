# Dotfiles (GNU Stow)

This tree replaces the Home Manager-managed dotfiles with plain files and GNU
Stow symlinks. Home Manager itself, the NixOS configuration, and the `shell/`
dev-shell flakes are **not** removed; they remain usable for rollback and for
the Nix-only pieces (dev shells, `nix-direnv`, optional `nixfmt`).

Nothing here is applied automatically. The install script places symlinks in
`$HOME`, fetches the pinned plugin assets, and copies `firefox/user.js` into an
existing Firefox profile; it does not install packages, edit `/etc`, or touch
Home Manager.

## Layout

```
stow/
  zsh/        .zshenv .aliases .profile .bashrc .hushlogin
              .config/zsh/{.zshrc,.zprofile,completion.zsh,git.zsh}
              .config/starship.toml
  git/        .config/git/config
              .config/lazygit/config.yml
  editor/     .config/nvim/**        (LazyVim, from home/dotfiles/config/lazyvim)
              .config/lvim/config.lua
              .config/helix/config.toml
  tmux/       .config/tmux/tmux.conf (TPM plugin lines)
  terminals/  .config/alacritty/alacritty.toml
              .config/wezterm/wezterm.lua
              .config/zellij/{config.kdl,layouts/default.kdl,README.md}
              .screenrc
  lf/         .config/lf/{lfrc,preview,colors,icons,icons_colored}
  hyprland/   .config/hypr/hyprland.conf   (Linux desktop only)
  bin/        .local/bin/{code,rustrover,rover}  (macOS only)

firefox/user.js               deployed by scripts/install-firefox-userjs.sh
scripts/install.sh            stow + bootstrap
scripts/bootstrap.sh          pinned zsh plugins, TPM, zellij wasm plugins
scripts/install-firefox-userjs.sh
scripts/uninstall.sh          stow -D guidance (Home Manager untouched)
```

Every directory mirrors `$HOME`; the target is always `$HOME`. Paths that need
runtime state (`~/.config/zsh`, `~/.config/tmux`, `~/.local/share/zellij`) are
created as real directories by `install.sh` before stowing, so plugin clones do
not end up inside this repository. `~/.local/share/zellij/plugins` is not
managed by Stow.

## Install

Prerequisites: `git`, `curl`, and GNU Stow. Install the native packages listed
below first (or at least `stow`, `git`, `curl`, `zsh`, `tmux`, `neovim`).

```sh
git clone https://github.com/rahul-r/dotfiles ~/.dotfiles
cd ~/.dotfiles

# inspect planned links without changing anything
scripts/install.sh --dry-run

scripts/install.sh
```

The script runs, in this order:

```sh
mkdir -p ~/.config/zsh ~/.config/tmux ~/.local/bin \
  ~/.local/share/zellij/plugins ~/.vim/undo
stow --restow --dir ~/.dotfiles/stow --target "$HOME" \
  zsh git editor tmux terminals lf hyprland     # Linux (not WSL)
# macOS: zsh git editor tmux terminals lf bin
scripts/bootstrap.sh
scripts/install-firefox-userjs.sh                # only if Firefox is present
```

If you prefer to run Stow by hand, create the runtime directories first (the
install script does this), then use exactly:

```sh
mkdir -p ~/.config/zsh ~/.config/tmux ~/.local/bin \
  ~/.local/share/zellij/plugins ~/.vim/undo
cd ~/.dotfiles
stow --restow --dir stow --target "$HOME" zsh git editor tmux terminals lf hyprland
```

Without those directories Stow folds `~/.config/zsh` into one symlink, and the
bootstrap clones would be written into this repository.

Stow refuses to overwrite existing files. If Home Manager still owns a path
(for example `~/.config/git/config` is a symlink into the Nix store), do not
use `--adopt` and do not delete the Home Manager generation. Either switch Home
Manager to a configuration that no longer declares that file, or remove just
that one symlink, then re-run. `--adopt` is never used here.

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

The Home Manager generation was never changed by this repository.

```sh
cd ~/.dotfiles
scripts/uninstall.sh            # dry run: prints the command and simulates it
scripts/uninstall.sh --apply    # removes the Stow symlinks
home-manager switch --flake .#blackhole   # or #macbook / #work-wsl, if desired
```

`uninstall.sh` does not remove Home Manager, packages, clones, or caches. To go
back to an earlier commit of these dotfiles, `git checkout` the desired commit
before running the install script again.

## Removal

```sh
scripts/uninstall.sh --apply
rm -rf ~/.dotfiles
```

Optionally remove the bootstrap data listed at the end of `uninstall.sh`'s
output. Home Manager still works if it was configured before; it only manages
the paths listed in `machines/*.nix` and `home/*.nix`.

## Migrated, omitted, manual

Migrated as byte-for-byte copies (`home/dotfiles/**`):
`.aliases`, `.profile`, `.bashrc`, `config/zsh/*`, `config/lf/*` (including the
executable `preview`), `config/alacritty/*`, `config/wezterm/*`,
`config/zellij/*`, `config/lazyvim/*` → `~/.config/nvim`, and
`config/lunarvim/config.lua` → `~/.config/lvim`.

Migrated as hand-written static files derived from the Home Manager settings:
`~/.zshenv`, `~/.hushlogin`, `~/.screenrc`, `~/.config/git/config`,
`~/.config/lazygit/config.yml`, `~/.config/starship.toml`,
`~/.config/helix/config.toml`, `~/.config/tmux/tmux.conf`,
`~/.config/hypr/hyprland.conf`, and `firefox/user.js`.

Intentionally omitted:

- Home Manager, the flake, `nixos/`, and `shell/` (unchanged, kept for Nix-only
  workflows and rollback).
- `home/dotfiles/config/nvim/` (the legacy, never-deployed Neovim tree) and
  `home/dotfiles/vimrc` (not deployed by the old configuration).
- `nix-switch`, nixGL wrappers, and the `/tmp/hyprland.desktop` activation
  hack. Native packages provide the session file and do not need nixGL.
- Firefox extension packages and fonts; these are manual steps below.

Manual steps:

- **Fonts**: install `DroidSansMono Nerd Font` and `UbuntuMono Nerd Font`.
  macOS: `brew install --cask font-droid-sans-mono-nerd-font
  font-ubuntu-mono-nerd-font`. Linux: unpack the Nerd Fonts release into
  `~/.local/share/fonts` and run `fc-cache -f`.
- **Firefox extensions**: install uBlock Origin and Bitwarden from
  addons.mozilla.org once. `user.js` cannot install extensions.
- **WSL git email**: the old `work-wsl` configuration used an empty
  `user.email`. The static config contains the approved address. On WSL,
  override it once with `git config --global user.email ""`; Git reads
  `~/.gitconfig` after `~/.config/git/config`, so this wins without editing the
  stowed file. Use `git config --global user.email jossb6cw@duck.com` to set it
  back.
- **fzf**: the copied rc files call `fzf-share` when available (the Nix
  package provided it). Distro packages may not; if completion/key bindings are
  missing, add `source <(fzf --zsh)` / `source <(fzf --bash)` yourself. The
  files were left unchanged.
- **git-lfs**: install the `git-lfs` package and run `git lfs install` once per
  machine. The filter settings are already in `~/.config/git/config`; the
  command installs the per-repository hooks.
- **Hyprland**: install Hyprland (and `waybar`, `swaybg`, `rofi`, `grimblast`,
  `nautilus`, `flatpak` with Brave) from your distro/COPR. The session entry is
  provided by the package under `/usr/share/wayland-sessions`; do not recreate
  `/tmp/hyprland.desktop`. nixGL is unnecessary with native packages.
- **LunarVim**: `~/.config/lvim` is installed, but the `lvim` binary comes from
  the LunarVim installer and is not managed here.
- **lf preview** needs `chafa`, `bat`, `glow` or `mdcat`, plus `lsix` for image
  listings. `lsix` is a single upstream script; put it in `~/bin` or
  `~/.local/bin`. Other preview branches need `ffmpegthumbnailer`, `pdftoppm`,
  `exiftool`, etc. (install only what you use).
- **nixfmt**: helix points at `nixfmt` on `PATH` (not a Nix store path).
  `cargo install nixfmt` or keep it available from Nix.
- **Neovim tooling**: the language servers/formatters were Home Manager
  packages. Install what you use with `pipx` and `npm -g` (see below).
- **rustup**: the old `install.sh` installed Rust. Install it yourself if you
  want it; nothing in these dotfiles depends on it at install time.
- **LazyVim**: first `nvim` run needs network access to download plugins.
- **TPM**: if plugins are missing, run `prefix + I` inside tmux.

## Native packages (verify availability)

The candidate names below come from the Phase 1 audit CSV. They were **not**
verified against live apt/dnf/brew indexes; check with `apt-cache search`,
`dnf search`, or `brew info` before installing. Use whichever package manager
your machine has; do not install all three.

### Shared (Linux + macOS)

```sh
# Debian/Ubuntu (names differ from Nix: fd-find, bat, git-delta)
sudo apt install stow git git-lfs git-delta tmux zsh curl \
  fzf zoxide bat direnv lf chafa ranger nodejs podman podman-compose \
  htop fd-find ripgrep eza duf neovim clang-tools cppcheck xsel \
  alacritty firefox
# verify: eza, duf, lf, zoxide, and a Node 24 build may need a PPA/universe
# Debian/Ubuntu rename two binaries: bat -> batcat, fd-find -> fdfind.
# Add ~/.local/bin/bat and ~/.local/bin/fd symlinks if you rely on them.

# Fedora (verify each; several are not in the official repos)
sudo dnf install stow git git-lfs git-delta tmux zsh curl \
  fzf zoxide bat direnv lf chafa ranger nodejs podman podman-compose \
  htop fd-find ripgrep eza duf neovim clang-tools-extra cppcheck xsel \
  alacritty firefox
# verify: lf, eza, duf, git-delta; use NodeSource/COPR/upstream where missing

# macOS
brew install stow git git-lfs git-delta tmux zsh curl \
  fzf zoxide bat direnv lf chafa ranger node podman podman-compose \
  htop fd ripgrep eza duf neovim llvm qemu coreutils \
  starship lazygit helix zellij lazydocker lemonade
brew install --cask alacritty wezterm neovide firefox \
  font-droid-sans-mono-nerd-font font-ubuntu-mono-nerd-font
```

Not in the official apt/dnf repos (upstream release, COPR/PPA, Homebrew on
Linux, or `cargo`): `starship`, `lazygit`, `helix`, `zellij`, `wezterm`,
`neovide`, `lazydocker`, `lemonade`, `lsix`, `hyprland`, `btrfs-assistant`,
the Nerd Fonts, and Node 24. `xsel` is Linux-only in the old config (Wayland
users may prefer `wl-clipboard`).

The macOS wrappers in `stow/bin/.local/bin` assume:

- `/Applications/Visual Studio Code.app`
- `/Applications/RustRover.app`

Both apps are installed manually (VS Code download, JetBrains Toolbox). On
Linux those wrappers are not stowed; use the real `code` binary if installed.

### Neovim tooling (choose one prefix)

```sh
pipx install yamllint flake8 beautysh mdformat pynvim cmakelang
npm install -g markdownlint-cli stylelint @fsouza/prettierd eslint neovim
```

`pynvim` must be visible to the Python interpreter Neovim uses. The Nix-only
pieces (`nix-direnv`, the `shell/` flakes, `nixfmt` if you keep it under Nix)
stay under Nix.
