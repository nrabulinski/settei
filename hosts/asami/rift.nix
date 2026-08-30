{ pkgs, ... }: {
  services.rift = {
    enable = true;
    # TODO: Remove once #553940 is merged
    package = pkgs.rift-wm.overrideAttrs (old: rec {
      version = "0.5.5";
      src = old.src.override {
        hash = "sha256-UQodikmxw6AexlPNkBjXSADX13/wRVExml387AxQp18=";
      };
      cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
        inherit src;
        hash = "sha256-wxymypJjczFqI9oivnVX/TOnR1KuupsaryQIQQVN7Gs=";
      };
      checkFlags = [
        "--skip=actor::reactor::tests::topology_change_clears_stale_pending_hide_target_before_next_workspace_layout"
        "--skip=actor::reactor::tests::best_space_prefers_authoritative_window_server_space_over_geometry"
      ];
    });
    config = {
      settings.default_disable = false;
      keys =
        let
          mod = "Meta";
          comb = "${mod} + Shift";
        in
        {
          "${mod} + Z" = "toggle_space_activated";

          "${mod} + H".move_focus = "left";
          "${mod} + J".move_focus = "down";
          "${mod} + K".move_focus = "up";
          "${mod} + L".move_focus = "right";

          "${comb} + H".move_node = "left";
          "${comb} + J".move_node = "down";
          "${comb} + K".move_node = "up";
          "${comb} + L".move_node = "right";

          "${mod} + 1".switch_to_workspace = 0;
          "${mod} + 2".switch_to_workspace = 1;
          "${mod} + 3".switch_to_workspace = 2;
          "${mod} + 4".switch_to_workspace = 3;

          "${comb} + 1".move_window_to_workspace = 0;
          "${comb} + 2".move_window_to_workspace = 1;
          "${comb} + 3".move_window_to_workspace = 2;
          "${comb} + 4".move_window_to_workspace = 3;

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
        };
    };
  };
}
