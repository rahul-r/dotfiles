#!/usr/bin/env bash

CWD=$(pwd)

if [ -z ${XDG_CONFIG_HOME+x} ]; then XDG_CONFIG_HOME=~/.config; fi

# For NixOS
# Desktop files for flatpaks use hardcoded '/usr/bin/flatpak' path but NixOS installs flatpak into a different location
# Create a symlink as a workaround
[[ -f /usr/bin/flatpak ]] || sudo ln -s /run/current-system/sw/bin/flatpak /usr/bin/flatpak

# For non NixOS systems
## Install Nix in multi-user mode (install only if not already installed)
[ -x "$(command -v nix)" ] || sh <(curl -L https://nixos.org/nix/install) --daemon --yes

# Add `experimental-features = nix-command flakes` to /etc/nix/nix.conf
sudo grep -qxF 'experimental-features = nix-command flakes' /etc/nix/nix.conf || echo 'experimental-features = nix-command flakes' | sudo tee -a /etc/nix/nix.conf

source /etc/profile
source ~/.profile

## Install home-manager (install only if not already installed)
if ! [ -x "$(command -v home-manager)" ]; then
	nix run home-manager/master -- init --switch
	rm -rf $XDG_CONFIG_HOME/home-manager
	ln -s ${CWD}/home-manager $XDG_CONFIG_HOME/home-manager
fi

# Activate home-manager configuration
home-manager switch -b nix_backup

# Install the vim plugins using vundle
# vim +PlugInstall +qall

# Install lunarvim
#bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh)

# Install rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --no-modify-path -y
