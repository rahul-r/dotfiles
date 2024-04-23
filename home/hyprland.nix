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
    waybar
    swaybg
    rofi
  ];

  wayland.windowManager.hyprland.enable = true;

  wayland.windowManager.hyprland.extraConfig = ''
    monitor=,preferred,auto,auto


    # Execute your favorite apps at launch
    # exec-once = waybar & hyprpaper & firefox
    exec-once = waybar

    # Source a file (multi-file configs)
    # source = ~/.config/hypr/myColors.conf

    # Wallpaper
    exec-once=swaybg -i ~/Pictures/Wallpapers/163856-taro_plant-plant-leaf-botany-terrestrial_plant-2560x1440.jpg -m fill

    # Some default env vars.
    env = XCURSOR_SIZE,24
    env = QT_QPA_PLATFORMTHEME,qt5ct # change to qt6ct if you have that

    env = LIBVA_DRIVER_NAME,nvidia
    env = XDG_SESSION_TYPE,wayland
    env = GBM_BACKEND,nvidia-drm
    env = __GLX_VENDOR_LIBRARY_NAME,nvidia
    env = WLR_NO_HARDWARE_CURSORS,1
  '';

  wayland.windowManager.hyprland.settings = {
    "$terminal" = "alacritty";
    "$fileManager" = "nautilus";
    "$webbrowser" = "firefox";
    "$menu" = "rofi -show drun";

    "$mod" = "SUPER";
    bind =
      [
        ", Print, exec, grimblast copy area"
        "$mod, RETURN, exec, $terminal"
        "$mod SHIFT, Q, killactive, "
        "$mod, M, exit, "
        "$mod, E, exec, $fileManager"
        "$mod, B, exec, $webbrowser"
        "$mod, V, togglefloating, "
        "$mod, R, exec, $menu"
        "ALT, SPACE, exec, $menu"
        "$mod, SHIFT R, exec, krunner"
        "$mod, P, pseudo, "# dwindle
        "$mod, T, togglesplit, "# dwindle

        # Move focus with mod + arrow keys
        "$mod, H, movefocus, l"
        "$mod, L, movefocus, r"
        "$mod, J, movefocus, u"
        "$mod, L, movefocus, d"

        # Switch workspaces with mod + [0-9]
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        # Move active window to a workspace with mod + SHIFT + [0-9]
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"

        # Example special workspace (scratchpad)
        "$mod, S, togglespecialworkspace, magic"
        "$mod SHIFT, S, movetoworkspace, special:magic"

        # Scroll through existing workspaces with mod + scroll
        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up, workspace, e-1"
      ]
      ++ (
        # workspaces
        # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
        builtins.concatLists (builtins.genList (
            x: let
              ws = let
                c = (x + 1) / 10;
              in
                builtins.toString (x + 1 - (c * 10));
            in [
              "$mod, ${ws}, workspace, ${toString (x + 1)}"
              "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
            ]
          )
          10)
      );
    bindm = [
      # Move/resize windows with mod + LMB/RMB and dragging
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
    ];

    input = {
        kb_layout = "us";
        kb_variant = "";
        kb_model = "";
        kb_options = "";
        kb_rules = "";

        follow_mouse = 1;

        touchpad = {
            natural_scroll = "no";
        };

        sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
    };

    general = {
        gaps_in = 5;
        gaps_out = 20;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";

        layout = "dwindle";
    };

    decoration = {
        rounding = 10;

        blur = {
            enabled = true;
            size = 3;
            passes = 1;
        };

        drop_shadow = "yes";
        shadow_range = 4;
        shadow_render_power = 3;
        "col.shadow" = "rgba(1a1a1aee)";
    };

    animations = {
        enabled = "yes";

        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";

        animation = "windows, 1, 7, myBezier";
        #animation = "windowsOut, 1, 7, default, popin 80%";
        #animation = "border, 1, 10, default";
        #animation = "borderangle, 1, 8, default";
        #animation = "fade, 1, 7, default";
        #animation = "workspaces, 1, 6, default";
    };

    dwindle = {
        pseudotile = "yes";
        preserve_split = "yes";
    };

    master = {
        new_is_master = true;
    };

    gestures = {
        workspace_swipe = "off";
    };

    misc = {
        force_default_wallpaper = -1; # Set to 0 or 1 to disable the anime mascot wallpapers
    };
  };
}
