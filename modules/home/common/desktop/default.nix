{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  _file = ./default.nix;

  options.common.desktop = {
    enable = lib.mkEnableOption "Common configuration for desktop machines";
  };

  config = lib.mkIf config.common.desktop.enable {
    home.packages = with pkgs; [
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

    programs.alacritty = {
      enable = true;
      settings = {
        cursor.style.shape = "Beam";
        window = {
          option_as_alt = lib.mkIf pkgs.stdenv.isDarwin "Both";
          decorations =
            if pkgs.stdenv.isDarwin
            then "Buttonless"
            else "None";
        };
        font.normal.family = "Iosevka Nerd Font";
      };
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
