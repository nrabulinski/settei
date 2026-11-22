{ lib, pkgs, ... }: {
  services.rift = {
    enable = true;
    package = pkgs.rift-wm.overrideAttrs (
      final: prev: {
        version = "0.8.6";
        src = prev.src.override {
          hash = "sha256-tX0BgpF9K24Q71WFZO/OhqT/S4o0u7GeBdaWXbhkb90=";
        };
        cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
          inherit (final) pname version src;
          hash = "sha256-dJsjOZklzevu6SyeOHynPlt3vU3iJzQE5v4Y5vCIe/4=";
        };
      }
    );
    config = {
      settings.default_disable = false;
      virtual_workspaces = {
        enabled = true;
        default_workspace_count = 9;
        workspace_auto_back_and_forth = true;
      };
      keys =
        let
          mod = "Meta";
          comb = "${mod} + Shift";

          mkWorkspaceConfig = num: {
            "${mod} + ${toString (num + 1)}".switch_to_workspace = num;
            "${comb} + ${toString (num + 1)}".move_window_to_workspace = num;
          };
          configs = builtins.genList mkWorkspaceConfig 9;
          configs' = lib.mergeAttrsList configs;
        in
        {
          "${comb} + Z" = "toggle_space_activated";

          "${mod} + H".move_focus = "left";
          "${mod} + J".move_focus = "down";
          "${mod} + K".move_focus = "up";
          "${mod} + L".move_focus = "right";

          "${comb} + H".move_node = "left";
          "${comb} + J".move_node = "down";
          "${comb} + K".move_node = "up";
          "${comb} + L".move_node = "right";

          "${mod} + Tab" = "switch_to_last_workspace";

          "${mod} + Shift + Left".join_window = "left";
          "${mod} + Shift + Right".join_window = "right";
          "${mod} + Shift + Up".join_window = "up";
          "${mod} + Shift + Down".join_window = "down";

          "${mod} + Comma" = "toggle_stack";
          "${mod} + Slash" = "toggle_orientation";

          "${mod} + Ctrl + E" = "unjoin_windows";

          "${comb} + Space" = "toggle_window_floating";

          "${comb} + F" = "toggle_fullscreen";

          "${mod} + Ctrl + Space" = "toggle_focus_floating";

          "${mod} + Shift + Equal" = "resize_window_grow";
          "${mod} + Shift + Minus" = "resize_window_shrink";

          "${mod} + Enter".exec = [ "/etc/profiles/per-user/niko/bin/wezterm" ];
        }
        // configs';
    };
  };
}
