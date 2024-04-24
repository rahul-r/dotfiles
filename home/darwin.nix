{
  inputs,
  outputs,
  config,
  lib,
  pkgs,
  ...
}:
{
  home.username = "rahul";
  home.homeDirectory = "/Users/rahul";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  imports = [
    ./zsh.nix
    ./tmux.nix
    ./git.nix
    ./neovim.nix
    ./helix.nix
  ];

  home.packages = with pkgs; [
    (pkgs.nerdfonts.override { fonts = [ "DroidSansMono" ]; })
    lf
    lsix
    chafa
    ranger
    podman
    podman-compose
    qemu
    neovide

    # Alternatives to traditional tools
    htop
    fd
    ripgrep
    fzf
    eza
    duf
  ];

  programs.zoxide.enable = true;

  home.file = {
    ".aliases".source = ./dotfiles/aliases;
    ".profile".source = ./dotfiles/profile;
    ".bashrc".source = ./dotfiles/bashrc;
  };

  xdg.configFile = {
    "alacritty".source = ./dotfiles/config/alacritty;
    "lf".source = ./dotfiles/config/lf;
  };

  home.activation = {
  };

  programs.bat.enable = true;

  home.sessionVariables = {
    EDITOR = "vi";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
