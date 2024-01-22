# TODO: Make this module not rely on OS config being present
{
  osConfig,
  pkgs,
  lib,
  inputs',
  machineName,
  ...
} @ args: let
  # TODO: Conditionally define based on whether we're in a system configuration or not
  fishOverlayModule = lib.mkIf (!args ? osConfig) {
    # See modules/system/common/default.nix for reasoning.
    nixpkgs.overlays = [(_: _: {inherit (inputs'.settei.packages) fish;})];
  };
in {
  _file = ./default.nix;

  imports = [
    ./desktop
    fishOverlayModule
  ];

  programs.fish.enable = true;
  programs.direnv.enable = true;
  programs.nix-index.enable = true;
  programs.ssh.enable = true;
  programs.zoxide.enable = true;
  programs.ripgrep.enable = true;
  programs.git = {
    enable = true;
    difftastic.enable = true;
    lfs.enable = true;
    userName = "Nikodem Rabuliński";
    userEmail = lib.mkDefault "nikodem@rabulinski.com";
    # TODO: settei options for home-manager module
    signing = {
      key = osConfig.settei.sane-defaults.allSshKeys.${machineName};
      signByDefault = true;
    };
    extraConfig = {
      gpg.format = "ssh";
      push.followTags = true;
    };
  };

  home.packages = [inputs'.settei.packages.base-packages pkgs.nh];

  home.sessionVariables.EDITOR = "hx";
}
