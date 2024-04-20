{ lib, pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    extraConfig = lib.fileContents ./dotfiles/config/tmux/tmux.conf;
    plugins = with pkgs; [
      tmuxPlugins.sensible
      tmuxPlugins.resurrect
      tmuxPlugins.continuum
      tmuxPlugins.catppuccin
      tmuxPlugins.vim-tmux-navigator
    ];
  };
}
