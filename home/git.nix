{ pkgs, ... }:
{
  home.packages = with pkgs; [ delta ];

  programs.git = {
    enable = true;
    userName = "Rahul";
    userEmail = "jossb6cw@duck.com";
    lfs.enable = true;
    extraConfig = {
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
        conflictstyle = "diff3";
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
      "git" = {
        "paging" = {
          "colorArg" = "always";
          "pager" = "delta --dark --paging=never";
        };
      };
    };
  };
}
