{
  config,
  lib,
  pkgs,
  inputs,
  inputs',
  ...
}:
{
  _file = ./default.nix;

  options.common.desktop = {
    enable = lib.mkEnableOption "Common configuration for desktop machines";
  };

  config = lib.mkIf config.common.desktop.enable {
    home.packages = with pkgs; [
      inputs'.settei.packages.wezterm
      nerdfonts
      fontconfig
    ];

    fonts.fontconfig.enable = true;

    programs.firefox = {
      enable = true;
      package =
        let
          firefox-pkgs = pkgs.extend inputs.firefox-darwin.overlay;
        in
        lib.mkIf pkgs.stdenv.isDarwin firefox-pkgs.firefox-bin;
    };

    programs.qutebrowser = {
      enable = true;
      package =
        if pkgs.stdenv.isDarwin then inputs'.niko-nur.packages.qutebrowser-bin else pkgs.qutebrowser;
      searchEngines = {
        r = "https://doc.rust-lang.org/stable/std/?search={}";
        lib = "https://lib.rs/search?q={}";
        nip = "https://jisho.org/search/{}";
      };
      settings = {
        tabs = {
          indicator.width = 3;
        };

        fonts = {
          default_family = "Iosevka";
          default_size = "13px";
        };

        content = {
          canvas_reading = true;
          blocking.method = "both";
          javascript.clipboard = "access";
        };
      };
      # Workaround because the nix module doesn't properly handle options that expect a dict
      extraConfig = ''
        c.tabs.padding = { 'top': 5, 'bottom': 5, 'right': 10, 'left': 10 }
        c.statusbar.padding = { 'top': 5, 'bottom': 5, 'right': 10, 'left': 10 }
      '';
      keyBindings = {
        passthrough = {
          "<Ctrl-Escape>" = "mode-leave";
        };
      };
    };

    programs.zellij = {
      enable = true;
      settings = {
        keybinds = {
          shared_except = {
            _args = [ "locked" ];
            unbind = "Ctrl q";
          };
        };
      };
    };

    xdg.configFile."zellij/layouts/compacter.kdl".text = ''
      layout {
        pane split_direction="vertical" {
          pane
        }

        pane size=1 borderless=true {
          plugin location="file:${inputs'.zjstatus.packages.default}/bin/zjstatus.wasm" {
            hide_frame_for_single_pane "true"

            format_left  "{mode}#[fg=fg,bg=bg,bold] {session}#[bg=bg] {tabs}"
            format_right "#[fg=#424554,bg=bg]::{datetime}"
            format_space "#[bg=bg]"

            mode_normal          "#[bg=green] "
            mode_locked          "#[bg=magenta] "
            mode_tab             "#[bg=blue] "
            mode_tmux            "#[bg=red] "
            mode_default_to_mode "tmux"

            tab_normal               "#[fg=#6C7086,bg=bg] {index} {name} {fullscreen_indicator}{sync_indicator}{floating_indicator}"
            tab_active               "#[fg=#9399B2,bg=bg,bold,italic] {index} {name} {fullscreen_indicator}{sync_indicator}{floating_indicator}"
            tab_fullscreen_indicator "□ "
            tab_sync_indicator       "  "
            tab_floating_indicator   "󰉈 "

            datetime          "#[fg=#9399B2,bg=bg] {format} "
            datetime_format   "%A, %d %b %Y %H:%M"
            datetime_timezone "Europe/Warsaw"
          }
        }
      }
    '';
  };
}
