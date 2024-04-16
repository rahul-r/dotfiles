#!/usr/bin/env bash

CWD=$(pwd)

# For NixOS
# To run flatpak in NixOS
# sudo ln -s /run/current-system/sw/bin/flatpak /usr/bin/flatpak
# Add `experimental-features = nix-command flakes` to /etc/nix/nix.conf

# For non NixOS systems
## Install Nix in multi-user mode
sh <(curl -L https://nixos.org/nix/install) --daemon
# Add `experimental-features = nix-command flakes` to /etc/nix/nix.conf

## Install home-manager
nix run home-manager/master -- init --switch
ln -s ${CWD}/home-manager $XDG_CONFIG_HOME/home-manager

# Activate home-manager configuration
home-manager switch
