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

  imports = [ ./zellij.nix ];

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
          default_family = "IosevkaTerm Nerd Font";
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
  };
}
