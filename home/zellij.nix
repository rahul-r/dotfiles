{ config, lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    zellij
  ];

  home.activation = {
    # This was using .config and mkOuOfStoreSymlink, but it is broken in recent nix
    # see https://github.com/nix-community/home-manager/issues/4692
    updateZellij = ''
      CONFIG_DIR="${config.home.homeDirectory}/.dotfiles/home/dotfiles/config"
      rm -f "''${XDG_CONFIG_HOME}/zellij" && ln -sf "''${CONFIG_DIR}/zellij" ''${XDG_CONFIG_HOME}/zellij
    '';
  };
}
