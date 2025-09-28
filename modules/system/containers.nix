{ isLinux }:
{
  config,
  lib,
  ...
}:
let
  containerModule =
    { name, ... }:
    {
      options = {
        config = lib.mkOption { type = lib.types.deferredModule; };
        hostAddress = lib.mkOption {
          type = lib.types.str;
          readOnly = true;
        };
        localAddress = lib.mkOption {
          type = lib.types.str;
          readOnly = true;
        };
        hostAddress6 = lib.mkOption {
          type = lib.types.str;
          readOnly = true;
        };
        localAddress6 = lib.mkOption {
          type = lib.types.str;
          readOnly = true;
        };
        autoStart = lib.mkOption {
          type = lib.types.bool;
          default = true;
        };
        bindMounts = lib.mkOption {
          type =
            with lib.types;
            attrsOf (submodule {
              options = {
                hostPath = lib.mkOption {
                  default = null;
                  example = "/home/alice";
                  type = nullOr str;
                  description = lib.mdDoc "Location of the host path to be mounted.";
                };
                isReadOnly = lib.mkOption {
                  default = true;
                  type = bool;
                  description = lib.mdDoc "Determine whether the mounted path will be accessed in read-only mode.";
                };
              };
            });
          default = { };
        };
      };

      config =
        let
          fullHash = builtins.hashString "sha256" name;
          getByte =
            idx:
            let
              i = idx * 2;
              s = builtins.substring i 2 fullHash;
            in
            (builtins.fromTOML "value = 0x${s}").value;
          netAddr = lib.genList getByte 2;
          net4 = "10.${lib.concatMapStringsSep "." toString netAddr}";
          net6 = "fc00:${lib.concatMapStrings lib.toHexString netAddr}:";
        in
        {
          hostAddress = "${net4}.1";
          localAddress = "${net4}.2";
          hostAddress6 = "${net6}:1";
          localAddress6 = "${net6}:2";
        };
    };

  linuxConfig = lib.optionalAttrs isLinux {
    containers = lib.mapAttrs (
      _: container:
      container
      // {
        config = {
          imports = [ container.config ];

          services.openssh.hostKeys = [ ];
          system.stateVersion = lib.mkDefault config.system.stateVersion;

          networking.useHostResolvConf = false;
          networking.nameservers = [
            "1.1.1.1"
            "1.0.0.1"
          ];
        };

        bindMounts = {
          # Pass in host's system key to allow decrypting secrets inside containers
          "/etc/ssh/ssh_host_ed25519_key" = { };
        }
        // container.bindMounts;

        privateNetwork = lib.mkForce true;
      }
    ) config.settei.containers;

    networking.nat = lib.mkIf (config.settei.containers != { }) {
      enable = true;
      internalInterfaces = [ "ve-+" ];
    };
  };

  darwinConfig = lib.optionalAttrs (!isLinux) {
    warnings = lib.optional (
      config.settei.containers != { }
    ) "settei.containers doesn't do anything on darwin yet";
  };
in
{
  _file = ./containers.nix;

  options.settei.containers = lib.mkOption {
    type = with lib.types; attrsOf (submodule containerModule);
    default = { };
  };

  config = lib.mkMerge [
    linuxConfig
    darwinConfig
  ];
}
