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
      rm ~/.config/nvim
      home-manager switch --flake ${config.home.homeDirectory}/.dotfiles#macbook
    '')

    (pkgs.writeShellScriptBin "rustrover" "/Applications/RustRover.app/Contents/MacOS/rustrover")
    (pkgs.writeShellScriptBin "rover" "/Applications/RustRover.app/Contents/MacOS/rustrover")
    (pkgs.writeShellScriptBin "code" ''"/Applications/Visual Studio Code.app/Contents/MacOS/Electron"'')

    qemu
    coreutils
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
