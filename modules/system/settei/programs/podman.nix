{isLinux}: {
  config,
  lib,
  pkgs,
  ...
}: let
  sharedConfig = {
    environment.systemPackages = [pkgs.podman-compose];
  };

  linuxConfig = lib.optionalAttrs isLinux {
    virtualisation.podman = {
      enable = true;
      dockerCompat = lib.mkDefault true;
      defaultNetwork.settings.dns_enabled = lib.mkDefault true;
    };
  };

  darwinConfig = lib.optionalAttrs (!isLinux) {
    environment.systemPackages = [pkgs.podman];
  };

  finalConfig = lib.mkMerge [
    sharedConfig
    linuxConfig
    darwinConfig
  ];
in {
  _file = ./podman.nix;

  options.settei.programs.podman.enable = lib.mkEnableOption "Podman";

  config = lib.mkIf config.settei.programs.podman.enable finalConfig;
}
