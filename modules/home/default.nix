# TODO: Make this module not rely on OS config being present
{
  osConfig,
  pkgs,
  lib,
  inputs',
  machineName,
  ...
}@args:
let
  # TODO: Conditionally define based on whether we're in a system configuration or not
  fishOverlayModule = lib.mkIf (!args ? osConfig) {
    # See modules/system/settei/default.nix for reasoning.
    nixpkgs.overlays = [ (_: _: { inherit (inputs'.settei.packages) fish; }) ];
  };
in
{
  _file = ./default.nix;

  imports = [
    ./desktop
    fishOverlayModule
    ./xdg.nix
    ./unfree.nix
  ];

  programs.home-manager.enable = true;
  programs.fish.enable = true;
  programs.nix-index.enable = true;
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
  };
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
      diff.algorithm = "histogram";
      diff.submodule = "log";
      status.submoduleSummary = true;
      help.autocorrect = "prompt";
      merge.conflictstyle = "zdiff3";
      branch.sort = "-committerdate";
      tag.sort = "taggerdate";
      log.date = "iso";
      rebase.missingCommitsCheck = "error";
    };
  };

  home.packages = [
    inputs'.settei.packages.base-packages
    pkgs.nh
  ];

  home.sessionVariables.EDITOR = "hx";
}
