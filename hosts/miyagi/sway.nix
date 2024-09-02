{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.greetd = {
    enable = true;
    settings.default_session =
      let
        swayWrapper = pkgs.writeShellScript "sway-wrapper" ''
          export XCURSOR_THEME=volantes_cursors
          exec ${lib.getExe config.programs.sway.package}
        '';
      in
      {
        command = "${lib.getExe pkgs.greetd.tuigreet} --time --cmd ${swayWrapper}";
        user = "niko";
      };
  };

  programs.sway = {
    enable = true;
    wrapperFeatures.base = true;
    wrapperFeatures.gtk = true;
  };

  security.pam.services.swaylock = { };
  xdg.portal.config.common.default = "*";

  settei.user.config =
    { config, ... }:
    {
      home.pointerCursor = {
        name = "volantes_cursors";
        package = pkgs.volantes-cursors;
      };

      home.packages = with pkgs; [
        (writeShellApplication {
          name = "lock";
          text = ''
            swaymsg output '*' power off
            swaylock -c 000000
            swaymsg output '*' power on
          '';
        })
        (writeShellApplication {
          name = "screenshot";
          runtimeInputs = [
            slurp
            grim
            wl-clipboard
          ];
          text = ''
            grim -g "$(slurp)" - | \
              wl-copy -t image/png
          '';
        })
        # Bitwarden stuff, move to separate module or properly package?
        # Maybe use some other input method?
        (rofi-rbw.override { waylandSupport = true; })
        rbw
        pinentry.curses
      ];

      wayland.windowManager.sway =
        let
          mod = config.wayland.windowManager.sway.config.modifier;
        in
        {
          enable = true;
          package = null;
          config.workspaceAutoBackAndForth = true;
          config.terminal = "wezterm";
          config.modifier = "Mod4";
          config.fonts.names = [ "IosevkaTerm Nerd Font" ];
          config.keybindings = lib.mkOptionDefault {
            "${mod}+b" = "exec rofi-rbw --selector rofi";
            "${mod}+d" = "exec rofi -show drun";
            "${mod}+Shift+s" = "exec screenshot";
          };
          config.keycodebindings = {
            "${mod}+Shift+60" = "exec lock";
          };
          config.window.commands =
            let
              alwaysFloating = [
                { window_role = "pop-up"; }
                { window_role = "bubble"; }
                { window_role = "dialog"; }
                { window_type = "dialog"; }
                { window_role = "task_dialog"; }
                { window_type = "menu"; }
                { app_id = "floating"; }
                { app_id = "floating_update"; }
                { class = "(?i)pinentry"; }
                { title = "Administrator privileges required"; }
                { title = "About Mozilla Firefox"; }
                { window_role = "About"; }
                {
                  app_id = "firefox";
                  title = "Library";
                }
              ];
            in
            map (criteria: {
              inherit criteria;
              command = "floating enable";
            }) alwaysFloating;
          config.output = {
            "HDMI-A-1" = {
              pos = "0 472";
            };
            "DP-1" = {
              pos = "2560 0";
              transform = "90";
            };
          };
          config.input = {
            "type:pointer" = {
              accel_profile = "flat";
              pointer_accel = "0.2";
            };
            "type:keyboard" = {
              xkb_layout = "pl";
            };
          };
          config.workspaceOutputAssign = [
            {
              workspace = "1";
              output = "HDMI-A-1";
            }
            {
              workspace = "2";
              output = "DP-1";
            }
          ];
          config.seat."*" = {
            xcursor_theme = "volantes_cursors 24";
          };
          config.startup = [
            {
              command = "${lib.getExe' pkgs.glib "gsettings"} set org.gnome.desktop.interface cursor-theme 'volantes_cursors'";
              always = true;
            }
          ];
        };
      programs.rofi = {
        enable = true;
        package = pkgs.rofi-wayland;
      };
    };
}
