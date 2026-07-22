{ pkgs, specialArgs, ... }:

{
  home.packages = with pkgs; [ delta ];

  programs.git = {
    enable = true;
    lfs.enable = true;

    settings = {
      user = {
        name = specialArgs.username;
        email = specialArgs.email;
      };

      alias = {
        lg = "lazygit";
      };

      core = {
        editor = "vi";
        pager = "delta";
      };

      interactive = {
        diffFilter = "delta --color-only";
      };

      delta = {
        navigate = true;
        features = [
          "line-numbers"
          "side-by-side"
        ];
      };

      merge = {
        conflictStyle = "diff3";
      };

      diff = {
        colorMoved = "default";
      };

      pull = {
        rebase = true;
      };
    };
  };

  programs.lazygit = {
    enable = true;

    settings = {
      git = {
        pagers = [
          {
            colorArg = "always";
            pager = "delta --dark --paging=never";
          }
        ];
      };
    };
  };
}
