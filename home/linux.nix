{
  inputs,
  outputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  nixGLWrap =
    pkg:
    pkgs.runCommand "${pkg.name}-nixgl-wrapper" { } ''
      mkdir $out
      ln -s ${pkg}/* $out
      rm $out/bin
      mkdir $out/bin
      for bin in ${pkg}/bin/*; do
       wrapped_bin=$out/bin/$(basename $bin)
       echo "exec ${lib.getExe pkgs.nixgl.nixGLIntel} $bin \$@" > $wrapped_bin
       chmod +x $wrapped_bin
      done
    '';
in
{
  home.username = "rahul";
  home.homeDirectory = "/home/rahul";

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
    ./firefox.nix
    ./helix.nix
    ./hyprland
  ];

  home.packages = with pkgs; [
    (pkgs.nerdfonts.override { fonts = [ "DroidSansMono" ]; })

    nixgl.nixGLIntel
    (nixGLWrap pkgs.alacritty)

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    vim
    clang-tools
    xsel
    lemonade
    cppcheck
    lf
    lsix
    chafa
    ranger
    btrfs-assistant
    typescript

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
    ".hushlogin".text = "";
    ".screenrc".text = ''
      term "screen-256color"
    '';

    # vim
    ".vimrc".source = ./dotfiles/vimrc;
    ".vim/autoload/plug.vim".source = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim";
      sha256 = "0llmchd6frnxkp2zqpbg8k5zq5jjbmln6g6ndfyy1nnxcf3gwm2y";
    };
    ".local/share/nvim/site/pack/packer/start/packer.nvim".source = builtins.fetchGit {
      url = "https://github.com/wbthomason/packer.nvim";
      rev = "ea0cc3c59f67c440c5ff0bbe4fb9420f4350b9a3";
    };
  };

  xdg.configFile = {
    "alacritty".source = ./dotfiles/config/alacritty;
    "lf".source = ./dotfiles/config/lf;
  };

  home.activation = {
    setupVim = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run mkdir -p ~/.vim/undo # && ~/.nix-profile/bin/vim +PlugInstall +qall
    '';
  };

  programs.bat.enable = true;

  home.sessionVariables = {
    EDITOR = "vi";
  };

  programs.man.enable = false;
  home.extraOutputsToInstall = [ "man" ];
  home.sessionVariables = {
    LANG = "en_US.UTF-8";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
