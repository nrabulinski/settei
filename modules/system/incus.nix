{ isLinux }:
{
  lib,
  config,
  pkgs,
  username,
  ...
}:
let
  inherit (lib) mkOption types;

  cfg = config.settei.incus;

  sharedConfig = {
    environment.systemPackages = [
      (cfg.clientPackage.overrideAttrs (prev: {
        postInstall = ''
          export HOME="$(mktemp -d)"
          mkdir -p "$HOME/.config/incus"
          ${prev.postInstall or ""}
        '';
      }))
    ];
  };

  linuxConfig = lib.optionalAttrs isLinux (
    lib.mkIf (!cfg.clientOnly) {
      virtualisation.incus = {
        enable = true;
        inherit (cfg) package clientPackage;
        preseed = {
          # TODO: Default profile with storage pool
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
      networking = {
        nftables.enable = true;
        firewall.trustedInterfaces = [ "incusbr0" ];
      };
      users.users.${username}.extraGroups = [ "incus-admin" ];
    }
  );

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

  options.settei.incus = {
    enable = lib.mkEnableOption "incus, the VM and container manager";
    clientOnly = mkOption {
      type = types.bool;
      default = !isLinux;
    };
    package = lib.mkPackageOption pkgs "incus" { };
    clientPackage = lib.mkOption {
      type = types.package;
      default = cfg.package.client;
      defaultText = lib.literalExpression "config.settei.incus.package.client";
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
