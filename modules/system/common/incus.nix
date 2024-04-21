{ isLinux }:
{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption types;

  cfg = config.common.incus;

  sharedConfig = {
    environment.systemPackages = [ cfg.clientPackage ];
  };

  linuxConfig = lib.optionalAttrs isLinux {
    virtualisation.incus = lib.mkIf (!cfg.clientOnly) {
      enable = true;
      inherit (cfg) package clientPackage;
      preseed = {
        networks = [
          {
            name = "incusbr0";
            type = "bridge";
            config = {
              "ipv4.address" = "10.0.100.1/24";
              "ipv4.nat" = "true";
            };
          }
        ];
        storage_pools = [
          {
            name = "default";
            driver = "dir";
            config = {
              source = "/var/lib/incus/storage-pools/default";
            };
          }
        ];
      };
    };
  };

  darwinConfig = lib.optionalAttrs (!isLinux) {
    assertions = [
      {
        assertion = cfg.enable -> cfg.clientOnly;
        message = "Darwin cannot be an incus host";
      }
    ];
  };
in
{
  _file = ./incus.nix;

  options.common.incus = {
    enable = lib.mkEnableOption "incus, the VM and container manager";
    clientOnly = mkOption {
      type = types.bool;
      default = !isLinux;
    };
    package = lib.mkPackageOption pkgs "incus" { };
    clientPackage = lib.mkOption {
      type = types.package;
      default = cfg.package.client;
      defaultText = lib.literalExpression "config.common.incus.package.client";
      description = "The incus client package to use. This package is added to PATH.";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      sharedConfig
      linuxConfig
      darwinConfig
    ]
  );
}
