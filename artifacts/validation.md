# Stow migration — dry-run validation

Date: 2026-10-24
Worktree: `/home/rahul/.dotfiles-stow` (branch `stow-migration`)
Scope: validation only. Nothing was stowed into the real `$HOME`, no `--adopt`
was used, and Home Manager was not modified.

## 1. Environment and target

`stow` is not installed in `$PATH`, so GNU Stow 2.4.1 was run from nixpkgs:

```console
$ nix run nixpkgs#stow -- --version
stow (GNU Stow) version 2.4.1
```

The requested target `/tmp/opencode/dryrun-stow` could not be created because
`/tmp/opencode` is owned by another user and is not writable by `rahul`:

```console
$ mkdir -p /tmp/opencode/dryrun-stow
mkdir: cannot create directory ‘/tmp/opencode/dryrun-stow’: Permission denied
$ ls -ld /tmp/opencode
drwxr-xr-x 6 agents agents 120 Oct 22 23:46 /tmp/opencode
```

Fallback used for all runs: `/tmp/dryrun-stow`, created empty:

```console
$ mkdir -p /tmp/dryrun-stow
$ find /tmp/dryrun-stow -mindepth 1 | wc -l
0
$ ls -ld /tmp/dryrun-stow
drwxr-xr-x 2 rahul rahul 40 Oct 24 00:20 /tmp/dryrun-stow
```

This is a deviation from the requested path, not from the dry-run rule.

## 2. Stow dry runs

### 2.1 Every package, empty target

```sh
cd /home/rahul/.dotfiles-stow
nix run nixpkgs#stow -- -v -n -d /home/rahul/.dotfiles-stow/stow \
  -t /tmp/dryrun-stow <package>
```

```console
===== stow -n zsh =====
LINK: .aliases => ../../home/rahul/.dotfiles-stow/stow/zsh/.aliases
LINK: .bashrc => ../../home/rahul/.dotfiles-stow/stow/zsh/.bashrc
LINK: .config => ../../home/rahul/.dotfiles-stow/stow/zsh/.config
LINK: .hushlogin => ../../home/rahul/.dotfiles-stow/stow/zsh/.hushlogin
LINK: .profile => ../../home/rahul/.dotfiles-stow/stow/zsh/.profile
LINK: .zshenv => ../../home/rahul/.dotfiles-stow/stow/zsh/.zshenv
WARNING: in simulation mode so not modifying filesystem.
===== stow -n git =====
LINK: .config => ../../home/rahul/.dotfiles-stow/stow/git/.config
WARNING: in simulation mode so not modifying filesystem.
===== stow -n editor =====
LINK: .config => ../../home/rahul/.dotfiles-stow/stow/editor/.config
WARNING: in simulation mode so not modifying filesystem.
===== stow -n tmux =====
LINK: .config => ../../home/rahul/.dotfiles-stow/stow/tmux/.config
WARNING: in simulation mode so not modifying filesystem.
===== stow -n terminals =====
LINK: .config => ../../home/rahul/.dotfiles-stow/stow/terminals/.config
LINK: .screenrc => ../../home/rahul/.dotfiles-stow/stow/terminals/.screenrc
WARNING: in simulation mode so not modifying filesystem.
===== stow -n lf =====
LINK: .config => ../../home/rahul/.dotfiles-stow/stow/lf/.config
WARNING: in simulation mode so not modifying filesystem.
===== stow -n hyprland =====
LINK: .config => ../../home/rahul/.dotfiles-stow/stow/hyprland/.config
WARNING: in simulation mode so not modifying filesystem.
===== stow -n bin =====
LINK: .local => ../../home/rahul/.dotfiles-stow/stow/bin/.local
WARNING: in simulation mode so not modifying filesystem.
```

On a completely empty target Stow folds each package's top directory. That is
expected and not the real layout: `$HOME` already has `.config` and `.local`.

### 2.2 Combined, empty target

```sh
nix run nixpkgs#stow -- -v -n -d /home/rahul/.dotfiles-stow/stow \
  -t /tmp/dryrun-stow zsh git editor tmux terminals lf hyprland bin
```

Stow merges the package trees instead of conflicting on the shared `.config`:

```console
LINK: .aliases => ../../home/rahul/.dotfiles-stow/stow/zsh/.aliases
LINK: .bashrc => ../../home/rahul/.dotfiles-stow/stow/zsh/.bashrc
LINK: .config => ../../home/rahul/.dotfiles-stow/stow/zsh/.config
LINK: .hushlogin => ../../home/rahul/.dotfiles-stow/stow/zsh/.hushlogin
LINK: .profile => ../../home/rahul/.dotfiles-stow/stow/zsh/.profile
LINK: .zshenv => ../../home/rahul/.dotfiles-stow/stow/zsh/.zshenv
UNLINK: .config (reverts previous action)
MKDIR: .config
LINK: .config/starship.toml => ../../../home/rahul/.dotfiles-stow/stow/zsh/.config/starship.toml
LINK: .config/zsh => ../../../home/rahul/.dotfiles-stow/stow/zsh/.config/zsh
LINK: .config/git => ../../../home/rahul/.dotfiles-stow/stow/git/.config/git
LINK: .config/lazygit => ../../../home/rahul/.dotfiles-stow/stow/git/.config/lazygit
LINK: .config/helix => ../../../home/rahul/.dotfiles-stow/stow/editor/.config/helix
LINK: .config/lvim => ../../../home/rahul/.dotfiles-stow/stow/editor/.config/lvim
LINK: .config/nvim => ../../../home/rahul/.dotfiles-stow/stow/editor/.config/nvim
LINK: .config/tmux => ../../../home/rahul/.dotfiles-stow/stow/tmux/.config/tmux
LINK: .config/alacritty => ../../../home/rahul/.dotfiles-stow/stow/terminals/.config/alacritty
LINK: .config/wezterm => ../../../home/rahul/.dotfiles-stow/stow/terminals/.config/wezterm
LINK: .config/zellij => ../../../home/rahul/.dotfiles-stow/stow/terminals/.config/zellij
LINK: .screenrc => ../../home/rahul/.dotfiles-stow/stow/terminals/.screenrc
LINK: .config/lf => ../../../home/rahul/.dotfiles-stow/stow/lf/.config/lf
LINK: .config/hypr => ../../../home/rahul/.dotfiles-stow/stow/hyprland/.config/hypr
LINK: .local => ../../home/rahul/.dotfiles-stow/stow/bin/.local
WARNING: in simulation mode so not modifying filesystem.
```

### 2.3 Combined, target with real `$HOME` parent directories

`install.sh` creates `~/.config/zsh`, `~/.config/tmux`, `~/.local/bin`, etc.
before stowing so runtime data does not land in the repo. Emulating that:

```sh
mkdir -p /tmp/dryrun-stow/.config/zsh /tmp/dryrun-stow/.config/tmux \
  /tmp/dryrun-stow/.local/bin /tmp/dryrun-stow/.local/share/zellij/plugins \
  /tmp/dryrun-stow/.vim/undo
nix run nixpkgs#stow -- -v -n -d /home/rahul/.dotfiles-stow/stow \
  -t /tmp/dryrun-stow zsh git editor tmux terminals lf hyprland bin
```

```console
LINK: .aliases => ../../home/rahul/.dotfiles-stow/stow/zsh/.aliases
LINK: .bashrc => ../../home/rahul/.dotfiles-stow/stow/zsh/.bashrc
LINK: .config/starship.toml => ../../../home/rahul/.dotfiles-stow/stow/zsh/.config/starship.toml
LINK: .config/zsh/.zprofile => ../../../../home/rahul/.dotfiles-stow/stow/zsh/.config/zsh/.zprofile
LINK: .config/zsh/.zshrc => ../../../../home/rahul/.dotfiles-stow/stow/zsh/.config/zsh/.zshrc
LINK: .config/zsh/completion.zsh => ../../../../home/rahul/.dotfiles-stow/stow/zsh/.config/zsh/completion.zsh
LINK: .config/zsh/git.zsh => ../../../../home/rahul/.dotfiles-stow/stow/zsh/.config/zsh/git.zsh
LINK: .hushlogin => ../../home/rahul/.dotfiles-stow/stow/zsh/.hushlogin
LINK: .profile => ../../home/rahul/.dotfiles-stow/stow/zsh/.profile
LINK: .zshenv => ../../home/rahul/.dotfiles-stow/stow/zsh/.zshenv
LINK: .config/git => ../../../home/rahul/.dotfiles-stow/stow/git/.config/git
LINK: .config/lazygit => ../../../home/rahul/.dotfiles-stow/stow/git/.config/lazygit
LINK: .config/helix => ../../../home/rahul/.dotfiles-stow/stow/editor/.config/helix
LINK: .config/lvim => ../../../home/rahul/.dotfiles-stow/stow/editor/.config/lvim
LINK: .config/nvim => ../../../home/rahul/.dotfiles-stow/stow/editor/.config/nvim
LINK: .config/tmux/tmux.conf => ../../../../home/rahul/.dotfiles-stow/stow/tmux/.config/tmux/tmux.conf
LINK: .config/alacritty => ../../../home/rahul/.dotfiles-stow/stow/terminals/.config/alacritty
LINK: .config/wezterm => ../../../home/rahul/.dotfiles-stow/stow/terminals/.config/wezterm
LINK: .config/zellij => ../../../home/rahul/.dotfiles-stow/stow/terminals/.config/zellij
LINK: .screenrc => ../../home/rahul/.dotfiles-stow/stow/terminals/.screenrc
LINK: .config/lf => ../../../home/rahul/.dotfiles-stow/stow/lf/.config/lf
LINK: .config/hypr => ../../../home/rahul/.dotfiles-stow/stow/hyprland/.config/hypr
LINK: .local/bin/code => ../../../../home/rahul/.dotfiles-stow/stow/bin/.local/bin/code
LINK: .local/bin/rover => ../../../../home/rahul/.dotfiles-stow/stow/bin/.local/bin/rover
LINK: .local/bin/rustrover => ../../../../home/rahul/.dotfiles-stow/stow/bin/.local/bin/rustrover
WARNING: in simulation mode so not modifying filesystem.
```

All planned symlinks stay below the target. `zsh` and `tmux` are real directories
with individual file links, so the bootstrap clones are not written into the
repository.

The exact flag combination used by `install.sh` was also dry-run (same output,
exit 0):

```sh
nix run nixpkgs#stow -- --restow --verbose=1 --no \
  --dir /home/rahul/.dotfiles-stow/stow --target /tmp/dryrun-restow \
  zsh git editor tmux terminals lf hyprland
```

### 2.4 No-folding spot check

Confirms the nested zellij README is not swallowed by Stow's default ignore
list:

```sh
nix run nixpkgs#stow -- -v -n --no-folding -d .../stow -t /tmp/dryrun-nofold terminals
```

```console
LINK: .config/zellij/README.md => ...
LINK: .config/zellij/config.kdl => ...
LINK: .config/zellij/layouts/default.kdl => ...
```

`stow/editor/.stow-local-ignore` disables Stow's default ignore list for that
package so LazyVim's `.gitignore` is deployed too:

```console
LINK: .config/nvim/.gitignore => ...
LINK: .config/nvim/.neoconf.json => ...
(21 links total)
```

## 3. Installer dry run

A `stow` shim on `PATH`:

```sh
#!/bin/sh
exec nix run nixpkgs#stow -- "$@"
```

```sh
HOME=/tmp/dryrun-install PATH=/tmp/stow-shim:$PATH \
  scripts/install.sh --dry-run --no-bootstrap
```

```console
would create: /tmp/dryrun-install/.config/zsh /tmp/dryrun-install/.config/tmux /tmp/dryrun-install/.local/bin /tmp/dryrun-install/.local/share/zellij/plugins /tmp/dryrun-install/.vim/undo
dry run: no files will be changed
stowing: zsh git editor tmux terminals lf hyprland
LINK: .aliases => ../../home/rahul/.dotfiles-stow/stow/zsh/.aliases
LINK: .bashrc => ../../home/rahul/.dotfiles-stow/stow/zsh/.bashrc
LINK: .config/starship.toml => ../../../home/rahul/.dotfiles-stow/stow/zsh/.config/starship.toml
LINK: .config/zsh/.zprofile => ../../../../home/rahul/.dotfiles-stow/stow/zsh/.config/zsh/.zprofile
LINK: .config/zsh/.zshrc => ../../../../home/rahul/.dotfiles-stow/stow/zsh/.config/zsh/.zshrc
LINK: .config/zsh/completion.zsh => ../../../../home/rahul/.dotfiles-stow/stow/zsh/.config/zsh/completion.zsh
LINK: .config/zsh/git.zsh => ../../../../home/rahul/.dotfiles-stow/stow/zsh/.config/zsh/git.zsh
LINK: .hushlogin => ../../home/rahul/.dotfiles-stow/stow/zsh/.hushlogin
LINK: .profile => ../../home/rahul/.dotfiles-stow/stow/zsh/.profile
LINK: .zshenv => ../../home/rahul/.dotfiles-stow/stow/zsh/.zshenv
LINK: .config/git => ../../../home/rahul/.dotfiles-stow/stow/git/.config/git
LINK: .config/lazygit => ../../../home/rahul/.dotfiles-stow/stow/git/.config/lazygit
LINK: .config/helix => ../../../home/rahul/.dotfiles-stow/stow/editor/.config/helix
LINK: .config/lvim => ../../../home/rahul/.dotfiles-stow/stow/editor/.config/lvim
LINK: .config/nvim => ../../../home/rahul/.dotfiles-stow/stow/editor/.config/nvim
LINK: .config/tmux/tmux.conf => ../../../../home/rahul/.dotfiles-stow/stow/tmux/.config/tmux/tmux.conf
LINK: .config/alacritty => ../../../home/rahul/.dotfiles-stow/stow/terminals/.config/alacritty
LINK: .config/wezterm => ../../../home/rahul/.dotfiles-stow/stow/terminals/.config/wezterm
LINK: .config/zellij => ../../../home/rahul/.dotfiles-stow/stow/terminals/.config/zellij
LINK: .screenrc => ../../home/rahul/.dotfiles-stow/stow/terminals/.screenrc
LINK: .config/lf => ../../../home/rahul/.dotfiles-stow/stow/lf/.config/lf
LINK: .config/hypr => ../../../home/rahul/.dotfiles-stow/stow/hyprland/.config/hypr
WARNING: in simulation mode so not modifying filesystem.

Next steps:
  - open a new shell (or re-source ~/.profile and ~/.config/zsh/.zshrc)
  - tmux: press prefix + I if the plugins were not installed automatically
  - Firefox: install uBlock Origin and Bitwarden manually
  - first nvim start downloads LazyVim plugins
  - fonts and remaining native packages: see README.md
```

`bin` is correctly absent on Linux; `hyprland` is added on non-WSL Linux and
`bin` on Darwin by the script.

`uninstall.sh` dry run against the same sandbox (nothing stowed) exits 0:

```console
$ HOME=/tmp/dryrun-install PATH=/tmp/stow-shim:$PATH scripts/uninstall.sh
Dry run only. Re-run with --apply to remove these links:
  stow --delete --dir /home/rahul/.dotfiles-stow/stow --target /tmp/dryrun-install zsh git editor tmux terminals lf hyprland
WARNING: in simulation mode so not modifying filesystem.
```

## 4. Bootstrap dry run and pinned assets

```console
$ HOME=/tmp/dryrun-install scripts/bootstrap.sh --dry-run
+ mkdir -p /tmp/dryrun-install/.config/zsh
+ git clone --quiet https://github.com/zsh-users/zsh-syntax-highlighting.git /tmp/dryrun-install/.config/zsh/syntax-highlighting
+ git -C /tmp/dryrun-install/.config/zsh/syntax-highlighting checkout --quiet e0165eaa730dd0fa321a6a6de74f092fe87630b0
+ mkdir -p /tmp/dryrun-install/.config/zsh
+ git clone --quiet https://github.com/zsh-users/zsh-autosuggestions.git /tmp/dryrun-install/.config/zsh/zsh-autosuggestions
+ git -C /tmp/dryrun-install/.config/zsh/zsh-autosuggestions checkout --quiet c3d4e576c9c86eac62884bd47c01f6faed043fc5
+ mkdir -p /tmp/dryrun-install/.config/tmux/plugins
+ git clone --quiet https://github.com/tmux-plugins/tpm.git /tmp/dryrun-install/.config/tmux/plugins/tpm
+ git -C /tmp/dryrun-install/.config/tmux/plugins/tpm checkout --quiet master
+ curl --fail --location --silent --show-error --output /tmp/dryrun-install/.local/share/zellij/plugins/zellij_forgot.wasm https://github.com/karimould/zellij-forgot/releases/download/0.3.0/zellij_forgot.wasm
+ curl --fail --location --silent --show-error --output /tmp/dryrun-install/.local/share/zellij/plugins/zjstatus.wasm https://github.com/dj95/zjstatus/releases/download/v0.14.0/zjstatus.wasm
+ curl --fail --location --silent --show-error --output /tmp/dryrun-install/.local/share/zellij/plugins/zj-docker.wasm https://github.com/dj95/zj-docker/releases/download/v0.2.0/zj-docker.wasm
```

The three pinned hashes were checked against the actual release assets:

```console
$ curl -fsSL -o ... https://github.com/karimould/zellij-forgot/releases/download/0.3.0/zellij_forgot.wasm
$ curl -fsSL -o ... https://github.com/dj95/zjstatus/releases/download/v0.14.0/zjstatus.wasm
$ curl -fsSL -o ... https://github.com/dj95/zj-docker/releases/download/v0.2.0/zj-docker.wasm
$ sha256sum *.wasm
24d4382976fa5738d21743b827c4efab715751804169b41bf598ad711de4645c  zellij_forgot.wasm
05b46c5a6a7f3a88809732e1fed5e8d6ebb4b558368772d8ac5ae3443a7c896a  zj-docker.wasm
4e53e7bd2cf544ebac3173f409e40972e811d11762293ab0331a540e23f44915  zjstatus.wasm
```

All three match the constants in `scripts/bootstrap.sh` (the SRI hashes from
`home/zellij.nix`).

## 5. Firefox user.js deployment test

Sandbox profile with a `profiles.ini` where `Default=1` is the second section:

```console
$ HOME=/tmp/dryrun-firefox2 scripts/install-firefox-userjs.sh
installed /home/rahul/.dotfiles-stow/firefox/user.js -> /tmp/dryrun-firefox2/.mozilla/firefox/abc123.default-release/user.js
$ head -3 /tmp/dryrun-firefox2/.mozilla/firefox/abc123.default-release/user.js
// Static replacement for Home Manager's programs.firefox settings.
// Deployed into the default profile by scripts/install-firefox-userjs.sh.

$ HOME=/tmp/dryrun-firefox2 scripts/install-firefox-userjs.sh   # after local edit
backed up existing user.js to /tmp/dryrun-firefox2/.mozilla/firefox/abc123.default-release/user.js.bak
installed /home/rahul/.dotfiles-stow/firefox/user.js -> /tmp/dryrun-firefox2/.mozilla/firefox/abc123.default-release/user.js
$ ls -1 /tmp/dryrun-firefox2/.mozilla/firefox/abc123.default-release/
user.js
user.js.bak
```

The script selects the default profile, backs up a differing existing file, and
never writes outside the profile directory.

## 6. Static checks

### 6.1 Shell syntax and shellcheck

```console
$ for f in scripts/*.sh; do bash -n "$f" && echo "bash -n OK: $f"; done
bash -n OK: scripts/bootstrap.sh
bash -n OK: scripts/install-firefox-userjs.sh
bash -n OK: scripts/install.sh
bash -n OK: scripts/uninstall.sh

$ nix run nixpkgs#shellcheck -- -x scripts/install.sh scripts/uninstall.sh scripts/bootstrap.sh scripts/install-firefox-userjs.sh
(no output; exit 0)
```

### 6.2 Byte-for-byte copies and intended edits

```console
OK byte-identical: aliases
OK byte-identical: bashrc
OK byte-identical: .zshrc
OK byte-identical: .zprofile
OK byte-identical: config/zsh/completion.zsh
OK byte-identical: config/zsh/git.zsh
OK tree identical: home/dotfiles/config/lf == stow/lf/.config/lf
OK tree identical: home/dotfiles/config/lazyvim == stow/editor/.config/nvim
OK tree identical: home/dotfiles/config/zellij == stow/terminals/.config/zellij
OK tree identical: home/dotfiles/config/alacritty == stow/terminals/.config/alacritty
OK byte-identical: wezterm.lua
OK byte-identical: lunarvim config.lua
```

Expected diffs, both intentional:

```diff
# .profile: only the missing LANG from home.sessionVariables was appended
 export HF_HOME=/mnt/data/ai/Models/huggingface
+
+# Locale (previously home.sessionVariables.LANG)
+export LANG=en_US.UTF-8

# tmux.conf: commented TPM block replaced by active plugin lines
-#set -g @plugin 'tmux-plugins/tpm'
+set -g @plugin 'tmux-plugins/tpm'
...
-#run '~/.config/tmux/plugins/tpm/tpm'
+run '~/.config/tmux/plugins/tpm/tpm'
```

`stow/lf/.config/lf/preview` kept mode 755:

```console
$ stat -c '%a %n' stow/lf/.config/lf/preview
755 stow/lf/.config/lf/preview
```

### 6.3 Generated config parsers

```console
$ GIT_CONFIG_NOSYSTEM=1 HOME=/tmp/dryrun-git git config --file stow/git/.config/git/config --list
user.email=jossb6cw@duck.com
user.name=rahul
alias.lg=lazygit
core.editor=vi
core.pager=delta
interactive.difffilter=delta --color-only
delta.navigate=true
delta.features=line-numbers
delta.features=side-by-side
merge.conflictstyle=diff3
diff.colormoved=default
pull.rebase=true
filter.lfs.clean=git-lfs clean -- %f
filter.lfs.process=git-lfs filter-process
filter.lfs.required=true
filter.lfs.smudge=git-lfs smudge -- %f

$ python3 -c 'tomllib.load(...)'   # starship.toml, helix/config.toml
OK TOML: stow/zsh/.config/starship.toml (9 top-level keys)
OK TOML: stow/editor/.config/helix/config.toml (4 top-level keys)

$ python3 -c 'yaml.safe_load(...)'   # lazygit/config.yml
OK YAML: {'git': {'pagers': [{'colorArg': 'always', 'pager': 'delta --dark --paging=never'}]}}

$ node --check firefox/user.js
OK JS syntax
```

### 6.4 Hyprland semantic comparison

The static conf was parsed and compared with the live Home Manager output,
normalizing whitespace, key order, and comments. 107 entries match, including
every bind, block, variable, and extraConfig line. The only live-entry difference
is the Nix-store systemd line, intentionally omitted:

```console
live entries: 108 static entries: 107
only in live:
  1 ('exec-once', '/nix/store/...-dbus-.../bin/dbus-update-activation-environment ...')
only in static:
brace balance: stow/hyprland/.config/hypr/hyprland.conf depth=0
```

The source settings' duplicate workspace binds are kept verbatim.

### 6.5 Live Home Manager output diffs

```console
$ diff -u ~/.config/starship.toml stow/zsh/.config/starship.toml
(no output)
$ diff -u ~/.config/lazygit/config.yml stow/git/.config/lazygit/config.yml
(no output)
$ diff -u ~/.config/helix/config.toml stow/editor/.config/helix/config.toml
# only the [[language]] nix/rust entries from home/helix.nix are added
```

`~/.config/git/config` differs only by the removed Nix-store `gpg` program path
and comment/ordering changes; all declared settings and the LFS filter match.

### 6.6 Repository hygiene

```console
$ grep -RIn '/nix/store' stow
none
$ grep -RIn '/home/rahul' stow scripts README.md firefox
none
$ grep -RIn 'jossb6cw@duck.com' stow scripts README.md firefox
stow/git/.config/git/config:5:	email = "jossb6cw@duck.com"
README.md:178:  ... git config --global user.email jossb6cw@duck.com ...
$ find stow -type l | wc -l
0
$ grep -RIn -- '--adopt' scripts stow firefox
none
```

`--adopt` appears only in README prose as an explicit warning.

## 7. Not run

- Any real `stow` / `stow --restow` application, including into the sandbox was
  not performed; only `stow -n` was used.
- `scripts/uninstall.sh --apply` (would need a real stow application first).
- TPM plugin installation and tmux runtime parsing (would clone into the
  sandbox and start a tmux server).
- Hyprland runtime validation (`hyprctl configerrors`) — Hyprland is not
  installed in this environment.
- LazyVim first run (network plugin download), LunarVim, Firefox UI, fonts.
- Home Manager activation against any machine.

## 8. Summary

| Check | Result |
|---|---|
| `stow -n` for all 8 packages, empty target | PASS |
| Combined `stow -n`, empty target (tree merge) | PASS |
| Combined `stow -n`, realistic `$HOME` parents | PASS |
| Requested target `/tmp/opencode/dryrun-stow` | BLOCKED (permission denied); used `/tmp/dryrun-stow` |
| `install.sh --dry-run` in sandbox | PASS |
| `bootstrap.sh --dry-run` | PASS |
| Pinned zellij wasm checksums | PASS |
| Firefox user.js deployment + backup | PASS |
| `bash -n` + shellcheck | PASS |
| Byte-for-byte copy checks | PASS |
| TOML/YAML/git-config/JS parsing | PASS |
| Hyprland semantic settings match | PASS (one Nix-only line omitted) |
| Real `$HOME` / Home Manager modification | NOT PERFORMED |

## Post-cleanup re-validation (Nix artifacts removed)

Date: 2026-10-24
Worktree: `/home/rahul/.dotfiles-stow` (branch `stow-migration`)

After removing `flake.nix`, `flake.lock`, `home.nix`, `utils.nix`, `install.sh`,
`machines/`, `home/`, `nixos/`, and `shell/`, the combined Stow dry run was
repeated against a fresh empty sandbox. The flags and package list are the same
as §2.2; only the sandbox path is new. Nothing was written into `$HOME`.

```console
$ nix run nixpkgs#stow -- --version
stow (GNU Stow) version 2.4.1

$ SB=$(mktemp -d /tmp/revalidate-stow.XXXXXX)
$ echo "entries before: $(find "$SB" -mindepth 1 | wc -l)"
entries before: 0
$ cd /home/rahul/.dotfiles-stow
$ nix run nixpkgs#stow -- -v -n -d /home/rahul/.dotfiles-stow/stow \
    -t "$SB" zsh git editor tmux terminals lf hyprland bin
LINK: .aliases => ../../home/rahul/.dotfiles-stow/stow/zsh/.aliases
LINK: .bashrc => ../../home/rahul/.dotfiles-stow/stow/zsh/.bashrc
LINK: .config => ../../home/rahul/.dotfiles-stow/stow/zsh/.config
LINK: .hushlogin => ../../home/rahul/.dotfiles-stow/stow/zsh/.hushlogin
LINK: .profile => ../../home/rahul/.dotfiles-stow/stow/zsh/.profile
LINK: .zshenv => ../../home/rahul/.dotfiles-stow/stow/zsh/.zshenv
UNLINK: .config (reverts previous action)
MKDIR: .config
LINK: .config/starship.toml => ../../../home/rahul/.dotfiles-stow/stow/zsh/.config/starship.toml
LINK: .config/zsh => ../../../home/rahul/.dotfiles-stow/stow/zsh/.config/zsh
LINK: .config/git => ../../../home/rahul/.dotfiles-stow/stow/git/.config/git
LINK: .config/lazygit => ../../../home/rahul/.dotfiles-stow/stow/git/.config/lazygit
LINK: .config/helix => ../../../home/rahul/.dotfiles-stow/stow/editor/.config/helix
LINK: .config/lvim => ../../../home/rahul/.dotfiles-stow/stow/editor/.config/lvim
LINK: .config/nvim => ../../../home/rahul/.dotfiles-stow/stow/editor/.config/nvim
LINK: .config/tmux => ../../../home/rahul/.dotfiles-stow/stow/tmux/.config/tmux
LINK: .config/alacritty => ../../../home/rahul/.dotfiles-stow/stow/terminals/.config/alacritty
LINK: .config/wezterm => ../../../home/rahul/.dotfiles-stow/stow/terminals/.config/wezterm
LINK: .config/zellij => ../../../home/rahul/.dotfiles-stow/stow/terminals/.config/zellij
LINK: .screenrc => ../../home/rahul/.dotfiles-stow/stow/terminals/.screenrc
LINK: .config/lf => ../../../home/rahul/.dotfiles-stow/stow/lf/.config/lf
LINK: .config/hypr => ../../../home/rahul/.dotfiles-stow/stow/hyprland/.config/hypr
LINK: .local => ../../home/rahul/.dotfiles-stow/stow/bin/.local
WARNING: in simulation mode so not modifying filesystem.
exit=0

$ echo "entries after: $(find "$SB" -mindepth 1 | wc -l)"
entries after: 0
```

The run produced the same 21 `LINK` lines, one `UNLINK`/`MKDIR` pair for the
shared `.config` tree, and the simulation warning as the pre-cleanup run. Exit
code `0`; the sandbox stayed empty, so this was a true dry run and the Stow
package tree is intact after the cleanup.

Result: **PASS**.
