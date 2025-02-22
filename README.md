Install nix and home-manager
```sh
git clone https://github.com/rahul-r/dotfiles ~/.dotfiles
cd ~/.dotfiles
./install.sh
```
Run `nix-switch` command to apply home-manager changes

## Update nix packages

```sh
nix flake update
nix-switch
```
