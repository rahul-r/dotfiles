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
  home.homeDirectory = "/Users/${specialArgs.username}";

  imports = [
    ./common.nix
    ../home/neovim.nix
  ];

  home.packages = with pkgs; [
    (pkgs.writeShellScriptBin "nix-switch" ''
      home-manager switch --flake ${config.home.homeDirectory}/.dotfiles#macbook
    '')

    qemu
  ];

  home.file = {
  };

  xdg.configFile = {
  };

  home.activation = {
  };

  home.sessionVariables = {
  };
}
