{
  inputs,
  outputs,
  config,
  lib,
  pkgs,
  specialArgs,
  ...
}:
{
  home.username = specialArgs.username;
  home.homeDirectory = "/home/${specialArgs.username}";

  imports = [
    ./common.nix
    ../home/neovim.nix
  ];

  home.packages = with pkgs; [
    (pkgs.writeShellScriptBin "nix-switch" ''
      home-manager switch --flake ${config.home.homeDirectory}/.dotfiles#work-wsl
    '')

    clang-tools
    xsel
    lemonade
    cppcheck
  ];

  home.file = {
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
