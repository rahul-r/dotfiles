#!/usr/bin/env bash

# For NixOS
# To run flatpak in NixOS
sudo ln -s /run/current-system/sw/bin/flatpak /usr/bin/flatpak
# Add `experimental-features = nix-command flakes` to /etc/nix/nix.conf

# For non NixOS systems
## Install Nix in multi-user mode
sh <(curl -L https://nixos.org/nix/install) --daemon

## Install home-manager
nix run home-manager/master -- init --switch
# home-manager files are in ~/.config/home-manager

# To activate home-manager configuration
home-manager switch
