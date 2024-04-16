{ config, lib, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
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

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    tmux
    alacritty
    htop
    vim
    fd
    fzf
    clang-tools
    xsel
    lemonade
    cppcheck
    ripgrep
    lazygit
    lf
    btrfs-assistant
    neovim
  ];
  
  programs.git = {
    enable = true;
    userName  = "Rahul";
    userEmail = "jossb6cw@duck.com";
    lfs.enable = true;
    extraConfig = {
        core = { editor = "vi"; };
	pull = { rebase = true; };
    };
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".aliases".source = ./home/aliases;
    ".profile".source = ./home/profile;
    ".bashrc".source = ./home/bashrc;
    ".zshrc".source = ./home/zsh/zshrc;
    ".zprofile".source = ./home/zsh/zprofile;
    ".zsh/completion.zsh".source = ./home/zsh/completion.zsh;
    ".zsh/git.zsh".source = ./home/zsh/git.zsh;
    ".zsh/syntax-highlighting".source = builtins.fetchGit {
      url = "https://github.com/zsh-users/zsh-syntax-highlighting.git";
      rev = "e0165eaa730dd0fa321a6a6de74f092fe87630b0";
    };
    ".zsh/zsh-autosuggestions".source = builtins.fetchGit {
      url = "https://github.com/zsh-users/zsh-autosuggestions";
      rev = "c3d4e576c9c86eac62884bd47c01f6faed043fc5";
    };

    ".screenrc".source = ./home/screenrc;

    ".vimrc".source = ./home/vimrc;
    ".vim/autoload/plug.vim".source = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim";
      sha256 = "0llmchd6frnxkp2zqpbg8k5zq5jjbmln6g6ndfyy1nnxcf3gwm2y";
    };
  };

  xdg.configFile = {
    "nvim".source = ./home/config/lazyvim;
    "lvim".source = ./home/config/lunarvim;
    "alacritty".source = ./home/config/alacritty;
    "tmux".source = ./home/config/tmux;
    "lf".source = ./home/config/lf;
  };

  home.activation = {
    setupVim = lib.hm.dag.entryAfter ["writeBoundary"] ''
      run mkdir -p ~/.vim/undo # && ~/.nix-profile/bin/vim +PlugInstall +qall
    '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/rahul/etc/profile.d/hm-session-vars.sh
  #
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
