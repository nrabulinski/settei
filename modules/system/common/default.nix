{ isLinux }:
{
  config,
  configurationName,
  lib,
  pkgs,
  inputs,
  inputs',
  username,
  ...
}:
let
  sharedConfig = {
    settei = {
      username = lib.mkDefault "niko";
      sane-defaults = {
        enable = lib.mkDefault true;
        tailnet = "discus-macaroni.ts.net";
      };
      flake-qol.enable = true;
      user = {
        enable = lib.mkDefault true;
        # TODO: Move to settei or leave here?
        extraArgs.machineName = configurationName;
        config.imports = [ inputs.settei.homeModules.common ];
      };
    };

    programs.fish.enable = true;
    users.users.${username}.shell = pkgs.fish;

    time.timeZone = lib.mkDefault "Europe/Warsaw";

    # NixOS' fish module doesn't allow setting what package to use for fish,
    # so I need to override the fish package.
    nixpkgs.overlays = [ (_: _: { inherit (inputs'.settei.packages) fish; }) ];

    nix.settings.allow-import-from-derivation = false;
    # TODO: Remove once config checking works with lix
    nix.checkConfig = false;
  };

  linuxConfig = lib.optionalAttrs isLinux {
    system.stateVersion = "22.05";

    # https://github.com/NixOS/nixpkgs/issues/254807
    boot.swraid.enable = false;

    i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

    settei.user.config = {
      services.ssh-agent.enable = true;
    };
  };

  darwinConfig = lib.optionalAttrs (!isLinux) {
    system.stateVersion = 4;

    # Every macOS ARM machine can emulate x86.
    nix.settings.extra-platforms = lib.mkIf pkgs.stdenv.isAarch64 [ "x86_64-darwin" ];
  };
in
{
  _file = ./default.nix;

  imports = [
    (import ./hercules.nix { inherit isLinux; })
    (import ./user.nix { inherit isLinux; })
    (import ./github-runner.nix { inherit isLinux; })
    (import ./incus.nix { inherit isLinux; })
  ];

  config = lib.mkMerge [
    sharedConfig
    linuxConfig
    darwinConfig
  ];
}
