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
    # Language servers, linters, formatters, etc.
    python312Packages.yamllint
    #python312Packages.black
    python312Packages.flake8
    python312Packages.beautysh
    python312Packages.mdformat
    python312Packages.pynvim
    cmake-format
    markdownlint-cli
    stylelint
    prettierd
    
    # FIX: nodePackages removed; these are now top-level attributes
    eslint
    neovim-node-client # Note: the node provider for neovim is mapped as neovim-node-client
  ];

  # FIX: Restored native Out-Of-Store symlinking, as the Nix bug is fixed
  xdg.configFile = {
    "nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/home/dotfiles/config/lazyvim";
    "lvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/home/dotfiles/config/lunarvim";
  };
}

