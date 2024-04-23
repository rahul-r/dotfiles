{ lib, pkgs, ... }:
{
  programs.helix = {
    enable = true;
    settings = {
      theme = "gruvbox";
      editor = {
        line-number = "relative";
        scroll-lines = 3;
        cursorline = true;
        auto-format = true;
        auto-save = false;
        bufferline = "multiple";
        insert-final-newline = false;
        cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };
        file-picker.hidden = false;
        statusline = {
          left = ["mode" "spinner"];
          center = ["file-name"];
          right = [
            "diagnostics"
            "selections"
            "position"
            "file-encoding"
            "file-line-ending"
            "file-type"
          ];
          separator = "│";
          mode.normal = "NORMAL";
          mode.insert = "INSERT";
          mode.select = "SELECT";
        };
        indent-guides = {
          render = true;
          character = "│"; # Some characters that work well: "▏", "┆", "┊", "⸽", "╎", "│"
          skip-levels = 1;
        };
      };
      keys = {
        normal = {
          esc = ["collapse_selection" "keep_primary_selection"];
          C-g = [":new" ":insert-output lazygit" ":buffer-close!" ":redraw"];
        };
      };
    };
    languages.language = [{
      name = "nix";
      auto-format = true;
      formatter.command = "${pkgs.nixfmt-classic}/bin/nixfmt-classic";
    } {
      name = "rust";
      auto-format = true;
    }];
  };
}
