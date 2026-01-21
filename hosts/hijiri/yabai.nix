{ lib, pkgs, ... }:
{
  services.yabai = {
    enable = true;
    enableScriptingAddition = true;
    config = {
      layout = "bsp";
      top_padding = 10;
      bottom_padding = 10;
      left_padding = 10;
      right_padding = 10;
      window_gap = 10;
      mouse_modifier = "cmd";
      window_topmost = "off";
      window_shadow = "float";
      mouse_follows_focus = "on";
    };
    extraConfig = ''
      yabai -m rule --add app="^Alacritty$" border=on
      yabai -m rule --add app="^System Settings$" manage=off
      yabai -m rule --add app="^SlackowWall$" manage=off

      yabai -m signal --add event=window_created action='yabai -m query --windows --window $YABAI_WINDOW_ID \
        | ${lib.getExe pkgs.jq} -er ".\"can-resize\" or .\"is-floating\"" \
        || yabai -m window $YABAI_WINDOW_ID --toggle float'
    '';
  };
}
