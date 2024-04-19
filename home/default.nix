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
  home.homeDirectory = "/home/rahul";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  imports = [ ./git.nix ];

  home.packages = with pkgs; [
    (pkgs.nerdfonts.override { fonts = [ "DroidSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    alacritty
    htop
    vim
    fd
    fzf
    eza
    duf
    clang-tools
    xsel
    lemonade
    cppcheck
    ripgrep
    lf
    ranger
    btrfs-assistant
    neovim
    # Language servers, linters, formetters, etc.
    python311Packages.yamllint
    python311Packages.black
    python311Packages.flake8
    python311Packages.beautysh
    python311Packages.mdformat
    python311Packages.pynvim
    typescript
    cmake-format
    markdownlint-cli
    stylelint
    prettierd
    nodePackages.eslint
    nodePackages.jsonlint
    nodePackages.neovim
  ];

  programs.zoxide.enable = true;

  programs.firefox = {
    enable = true;
    profiles.default = {
      bookmarks = { };
      extensions = with inputs.firefox-addons.packages.${pkgs.system}; [
        ublock-origin
        bitwarden
      ];
      settings = {
        "browser.disableResetPrompt" = true;
        "browser.download.panel.shown" = true;
        "browser.download.useDownloadDir" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.shell.defaultBrowserCheckCount" = 1;
        "browser.startup.homepage" = "https://start.duckduckgo.com";
        "browser.uiCustomization.state" = ''{"placements":{"widget-overflow-fixed-list":[],"nav-bar":["back-button","forward-button","stop-reload-button","home-button","urlbar-container","downloads-button","library-button","ublock0_raymondhill_net-browser-action","_testpilot-containers-browser-action"],"toolbar-menubar":["menubar-items"],"TabsToolbar":["tabbrowser-tabs","new-tab-button","alltabs-button"],"PersonalToolbar":["import-button","personal-bookmarks"]},"seen":["save-to-pocket-button","developer-button","ublock0_raymondhill_net-browser-action","_testpilot-containers-browser-action"],"dirtyAreaCache":["nav-bar","PersonalToolbar","toolbar-menubar","TabsToolbar","widget-overflow-fixed-list"],"currentVersion":18,"newElementCount":4}'';
        "dom.security.https_only_mode" = true;
        "identity.fxaccounts.enabled" = false;
        "privacy.trackingprotection.enabled" = true;
        "signon.rememberSignons" = false;
      };
    };
  };

  home.file = {
    ".aliases".source = ./dotfiles/aliases;
    ".profile".source = ./dotfiles/profile;
    ".bashrc".source = ./dotfiles/bashrc;
    ".zshenv".text = ''
      export XDG_CONFIG_HOME=$HOME/.config
      export ZDOTDIR=$XDG_CONFIG_HOME/zsh
    '';
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
    "zsh/.zshrc".source = ./dotfiles/config/zsh/zshrc;
    "zsh/.zprofile".source = ./dotfiles/config/zsh/zprofile;
    "zsh/completion.zsh".source = ./dotfiles/config/zsh/completion.zsh;
    "zsh/git.zsh".source = ./dotfiles/config/zsh/git.zsh;
    "zsh/syntax-highlighting".source = builtins.fetchGit {
      url = "https://github.com/zsh-users/zsh-syntax-highlighting.git";
      rev = "e0165eaa730dd0fa321a6a6de74f092fe87630b0";
    };
    "zsh/zsh-autosuggestions".source = builtins.fetchGit {
      url = "https://github.com/zsh-users/zsh-autosuggestions";
      rev = "c3d4e576c9c86eac62884bd47c01f6faed043fc5";
    };

    #"nvim".source = ./dotfiles/config/nvim; # My custom neovim config
    "nvim".source = ./dotfiles/config/lazyvim;
    "lvim".source = ./dotfiles/config/lunarvim;
    "alacritty".source = ./dotfiles/config/alacritty;
    "lf".source = ./dotfiles/config/lf;
  };

  home.activation = {
    setupVim = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run mkdir -p ~/.vim/undo # && ~/.nix-profile/bin/vim +PlugInstall +qall
    '';
  };

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
