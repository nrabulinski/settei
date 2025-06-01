{
  config,
  lib,
  pkgs,
  inputs',
  ...
}:
{
  _file = ./default.nix;

  imports = [ ./zellij.nix ];

  options.settei.desktop = {
    enable = lib.mkEnableOption "Common configuration for desktop machines";
  };

  config = lib.mkIf config.settei.desktop.enable {
    home.packages = with pkgs; [
      inputs'.settei.packages.wezterm
      nerd-fonts.iosevka
      nerd-fonts.iosevka-term
      fontconfig
      signal-desktop-bin
    ];
    settei.unfree.allowedPackages = [ "signal-desktop-bin" ];

    fonts.fontconfig.enable = true;

    programs.firefox.enable = true;

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
