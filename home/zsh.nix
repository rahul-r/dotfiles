{ ... }:
{
  home.file = {
    ".zshenv".text = ''
      export XDG_CONFIG_HOME=$HOME/.config
      export ZDOTDIR=$XDG_CONFIG_HOME/zsh
    '';
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
  };
}
