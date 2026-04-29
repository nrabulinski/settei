{
  config,
  lib,
  pkgs,
  inputs',
  ...
}:
{
  _file = ./default.nix;

  imports = [
    ./zellij.nix
    ./atuin.nix
  ];

  options.settei.desktop = {
    enable = lib.mkEnableOption "Common configuration for desktop machines";
  };

  config = lib.mkIf config.settei.desktop.enable {
    home.packages = with pkgs; [
      inputs'.settei.packages.wezterm
      nerd-fonts.iosevka
      nerd-fonts.iosevka-term
      fontconfig
      signal-desktop
    ];

    fonts.fontconfig.enable = true;

    programs.firefox = {
      enable = true;
      configPath =
        if pkgs.stdenv.hostPlatform.isDarwin then
          "Library/Application Support/Firefox"
        else
          "${config.xdg.configHome}/mozilla/firefox";
    };
  };
}
