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

    xdg.configFile."zellij/layouts/compacter.kdl".text = config.lib.generators.toKDL { } {
      layout = {
        pane = {
          _props.split_direction = "vertical";
          pane = [ ];
        };

        pane = {
          _props = {
            size = 1;
            borderless = true;
          };

          plugin = {
            _props.location = "file:${inputs'.zjstatus.packages.default}/bin/zjstatus.wasm";

            hide_frame_for_single_pane = "true";

            format_left = "{mode}#[fg=#89B4FA,bg=#181825,bold] {session}#[bg=#181825] {tabs}";
            format_right = "#[fg=#424554,bg=#181825]::{datetime}";
            format_space = "#[bg=#181825]";

            mode_normal = "#[bg=#89B4FA] ";
            mode_tmux = "#[bg=#ffc387] ";
            mode_default_to_mode = "tmux";

            tab_normal = "#[fg=#6C7086,bg=#181825] {index} {name} {fullscreen_indicator}{sync_indicator}{floating_indicator}";
            tab_active = "#[fg=#9399B2,bg=#181825,bold,italic] {index} {name} {fullscreen_indicator}{sync_indicator}{floating_indicator}";
            tab_fullscreen_indicator = "□ ";
            tab_sync_indicator = "  ";
            tab_floating_indicator = "󰉈 ";

            datetime = "#[fg=#9399B2,bg=#181825] {format} ";
            datetime_format = "%A, %d %b %Y %H:%M";
            datetime_timezone = "Europe/Warsaw";
          };
        };
      };
    };
  };
}
