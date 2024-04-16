#!/usr/bin/env bash

CWD=$(pwd)

if [ -z ${XDG_CONFIG_HOME+x} ]; then XDG_CONFIG_HOME=~/.config; fi

# For NixOS
# To run flatpak in NixOS
# sudo ln -s /run/current-system/sw/bin/flatpak /usr/bin/flatpak
# Add `experimental-features = nix-command flakes` to /etc/nix/nix.conf

# For non NixOS systems
## Install Nix in multi-user mode
sh <(curl -L https://nixos.org/nix/install) --daemon
# Add `experimental-features = nix-command flakes` to /etc/nix/nix.conf
sudo grep -qxF 'experimental-features = nix-command flakes' /etc/nix/nix.conf || echo 'experimental-features = nix-command flakes'  | sudo tee -a /etc/nix/nix.conf

source /etc/profile
source ~/profile

## Install home-manager
nix run home-manager/master -- init --switch
rm -rf $XDG_CONFIG_HOME/home-manager
ln -s ${CWD}/home-manager $XDG_CONFIG_HOME/home-manager

# Activate home-manager configuration
home-manager switch
