{
  inputs,
  outputs,
  config,
  lib,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    neovim
    # Language servers, linters, formetters, etc.
    python311Packages.yamllint
    python311Packages.black
    python311Packages.flake8
    python311Packages.beautysh
    python311Packages.mdformat
    python311Packages.pynvim
    cmake-format
    markdownlint-cli
    stylelint
    prettierd
    nodePackages.eslint
    nodePackages.jsonlint
    nodePackages.neovim
  ];

  xdg.configFile = {
    #"nvim".source = ./dotfiles/config/nvim; # My custom neovim config
    "nvim".source = ./dotfiles/config/lazyvim;
    "lvim".source = ./dotfiles/config/lunarvim;
  };

  home.activation = {
    # This was using .config and mkOuOfStoreSymlink, but it is broken in recent nix
    # see https://github.com/nix-community/home-manager/issues/4692
    updateNeovimLinks = ''
      CONFIG_DIR="${config.home.homeDirectory}/.dotfiles/home/dotfiles/config"
      rm -f "''${XDG_CONFIG_HOME}/nvim" && ln -sf "''${CONFIG_DIR}/lazyvim" ''${XDG_CONFIG_HOME}/nvim
    '';
  };
}
