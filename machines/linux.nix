{
  inputs,
  outputs,
  config,
  lib,
  pkgs,
  specialArgs,
  ...
}:
let
  utils = import ../utils.nix {
    inherit pkgs;
    inherit lib;
    inherit config;
  };
in
{
  home.username = specialArgs.username;
  home.homeDirectory = "/home/${specialArgs.username}";

  imports = [
    ./common.nix
    ../home/neovim-nightly.nix
    ../home/firefox.nix
    ../home/hyprland
  ];

  home.packages = with pkgs; [
    (pkgs.writeShellScriptBin "nix-switch" ''
      home-manager switch --flake ${config.home.homeDirectory}/.dotfiles#blackhole
    '')

    nixgl.nixGLIntel

    (utils.nixGLWrapIntel alacritty)
    (utils.nixGLWrapIntel wezterm)

    clang-tools
    xsel
    lemonade
    cppcheck
    btrfs-assistant
  ];

  home.file = {
    ".screenrc".text = ''
      term "screen-256color"
    '';
  };

  xdg.configFile = {
  };

  home.activation = {
  };

  home.sessionVariables = {
  };

  programs.man.enable = false;
  home.extraOutputsToInstall = [ "man" ];
  home.sessionVariables = {
    LANG = "en_US.UTF-8";
  };
}
