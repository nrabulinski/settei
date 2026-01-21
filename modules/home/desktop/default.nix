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
    ./qutebrowser.nix
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
      signal-desktop-bin
    ];
    settei.unfree.allowedPackages = [
      "signal-desktop-bin"
      # TODO: Remove once hydra builds firefox for darwin
      "firefox-bin"
      "firefox-bin-unwrapped"
    ];

    fonts.fontconfig.enable = true;

    programs.firefox.enable = true;
    programs.firefox.package = pkgs.firefox-bin;
  };
}
