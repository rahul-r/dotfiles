{ config, lib, pkgs, ... }:
let
  PLUGIN_DIR = ".local/share/zellij/plugins";
in
{
  home.packages = with pkgs; [
    zellij
  ];

  home.file = {
    "${PLUGIN_DIR}/zellij_forgot.wasm" = {
      source = pkgs.fetchurl {
        url = "https://github.com/karimould/zellij-forgot/releases/download/0.3.0/zellij_forgot.wasm";
        sha256 = "sha256-JNQ4KXb6VzjSF0O4J8Tvq3FXUYBBabQb9ZitcR3kZFw=";
      };
    };
    "${PLUGIN_DIR}/zjstatus.wasm" = {
      source = pkgs.fetchurl {
        url = "https://github.com/dj95/zjstatus/releases/download/v0.14.0/zjstatus.wasm";
        sha256 = "sha256-TlPnvSz1ROusMXP0CeQJcugR0RdiKTqwMxpUDiP0SRU=";
      };
    };
    "${PLUGIN_DIR}/zj-docker.wasm" = {
      source = pkgs.fetchurl {
        url = "https://github.com/dj95/zj-docker/releases/download/v0.2.0/zj-docker.wasm";
        sha256 = "sha256-BbRsWmp/OoiAlzLh/tXo1uu0tVg2h3LYrFrjRDp8iWo=";
      };
    };
  };

  home.activation = {
    # This was using .config and mkOuOfStoreSymlink, but it is broken in recent nix
    # see https://github.com/nix-community/home-manager/issues/4692
    updateZellij = ''
      CONFIG_DIR="${config.home.homeDirectory}/.dotfiles/home/dotfiles/config"
      rm -f "''${XDG_CONFIG_HOME}/zellij" && ln -sf "''${CONFIG_DIR}/zellij" ''${XDG_CONFIG_HOME}/zellij
    '';
  };
}
