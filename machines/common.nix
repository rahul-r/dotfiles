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
  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  imports = [
    ../home/zsh.nix
    ../home/tmux.nix
    ../home/git.nix
    ../home/helix.nix
    ../home/zellij.nix
  ];

  home.packages = with pkgs; [
    nerd-fonts.droid-sans-mono
    nerd-fonts.ubuntu-mono

    lf
    lsix
    chafa
    ranger

    nodejs_20

    podman
    podman-compose
    lazydocker
    neovide

    # Alternatives to traditional tools
    htop
    fd
    ripgrep
    fzf
    eza
    duf
  ];

  #programs.wezterm.enable = true;
  #programs.wezterm.extraConfig = builtins.readFile ./dotfiles/config/wezterm/wezterm.lua;
  programs.zoxide.enable = true;

  programs.bat.enable = true;

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;

      line_break = {
        disabled = true;
      };

      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };

      hostname = {
        ssh = {
          format = "[$hostname](bold yellow)";
        };
        format = "[$ssh_symbol](bold blue)[$hostname](bold red) ";
        ssh_only = true;
        disabled = true;
        detect_env_vars = ["!TMUX" "SSH_CONNECTION"]; # Hide the hostname in remote tmux sessions
      };
      username = {
        format = "[$user]($style)";
        disabled = true;
      };
      directory = {
        format = "[$path]($style)[$read_only]($read_only_style) ";
      };
      git_status = { disabled = true; };
      git_commit = { disabled = true; };
      git_branch = { format = "[$symbol$branch(:$remote_branch)]($style) "; };
    };
  };

  programs.direnv = {
    enable = true;
    silent = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  home.file = {
    ".aliases".source = ../home/dotfiles/aliases;
    ".profile".source = ../home/dotfiles/profile;
    ".bashrc".source = ../home/dotfiles/bashrc;
    ".hushlogin".text = "";

    # vim
    ".vimrc".source = ../home/dotfiles/vimrc;
    ".vim/autoload/plug.vim".source = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim";
      sha256 = "sha256:01kkg3c05si97r4kkdhn5n17kcqp56hjh4d74l9aajd0d629kn62";
    };
    ".local/share/nvim/site/pack/packer/start/packer.nvim".source = builtins.fetchGit {
      url = "https://github.com/wbthomason/packer.nvim";
      rev = "ea0cc3c59f67c440c5ff0bbe4fb9420f4350b9a3";
    };
  };

  xdg.configFile = {
    "alacritty".source = ../home/dotfiles/config/alacritty;
    # https://github.com/nix-community/home-manager/issues/4692
    #"wezterm".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/home/dotfiles/config/wezterm";
    "lf".source = ../home/dotfiles/config/lf;
  };

  home.activation = {
    setupVim = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run mkdir -p ~/.vim/undo # && ~/.nix-profile/bin/vim +PlugInstall +qall
    '';
    # This was using .config and mkOuOfStoreSymlink, but it is broken in recent nix
    # see https://github.com/nix-community/home-manager/issues/4692
    updateLinks = ''
      CONFIG_DIR="${config.home.homeDirectory}/.dotfiles/home/dotfiles/config"
      rm -f "''${XDG_CONFIG_HOME}/wezterm" && ln -sf "''${CONFIG_DIR}/wezterm" ''${XDG_CONFIG_HOME}/wezterm
    '';
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  programs.man.enable = false;
  home.extraOutputsToInstall = [ "man" ];
  home.sessionVariables = {
    LANG = "en_US.UTF-8";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
