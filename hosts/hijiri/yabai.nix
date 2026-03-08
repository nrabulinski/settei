{ lib, pkgs, ... }:
{
  environment.systemPackages = [
    # Copied from https://github.com/asmvik/yabai/issues/2686#issuecomment-3678216885
    (pkgs.writeShellScriptBin "yabai-load-sa" ''
      yabai --load-sa && exit

      patch_caps() {
          [ ! -f "$1" ] && echo "Error: '$1' not found" && return 1

          # Get index (I) and offset (O) for caps 0x81
          read I O <<< $(otool -f "$1" | awk '/architecture/{i=$2} /capabilities 0x81/{f=1} f&&/offset/{print i, $2; exit}')

          if [ -n "$O" ]; then
              # Patch Fat (offset+4) and Mach-O (slice+11) -> 0x80
              printf '\x80' | dd of="$1" bs=1 seek=$((8 + I*20 + 4)) count=1 conv=notrunc 2>/dev/null
              printf '\x80' | dd of="$1" bs=1 seek=$((O + 11)) count=1 conv=notrunc 2>/dev/null
        
              echo "Patched $1 (Arch $I). Resigning..."
              codesign -f -s - "$1" &>/dev/null
          else
              echo "No target architecture (caps 0x81) found in '$1'."
          fi
      }

      patch_caps "/Library/ScriptingAdditions/yabai.osax/Contents/MacOS/loader"
      yabai --load-sa
    '')
  ];

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
