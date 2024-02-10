{
  config,
  lib,
  pkgs,
  inputs,
  inputs',
  ...
}: {
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
      package = let
        firefox-pkgs = pkgs.extend inputs.firefox-darwin.overlay;
      in
        lib.mkIf pkgs.stdenv.isDarwin firefox-pkgs.firefox-bin;
    };

    programs.qutebrowser = {
      enable = true;
      package =
        if pkgs.stdenv.isDarwin
        then inputs'.niko-nur.packages.qutebrowser-bin
        else pkgs.qutebrowser;
    };

    programs.zellij = {
      enable = true;
      settings = {
        keybinds = {
          shared_except = {
            _args = ["locked"];
            unbind = "Ctrl q";
          };
        };
      };
    };
  };
}
