
{ lib, pkgs, ... }:
{
  # home.packages = with pkgs; [
  #   (utils.nixGLWrapIntel wezterm)
  # ];

  programs.wezterm = {
    enable = true;
    enableNixGL = true;
  };
}
