{ isLinux }:
{
  config,
  options,
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
        };
      };

      config =
        let
          fullHash = builtins.hashString "sha256" name;
          getByte =
            idx:
            let
              i = idx * 2;
              s = builtins.substring i (i + 2) fullHash;
            in
            (builtins.fromTOML "value = 0x${s}").value;
          netAddr = lib.genList getByte 2;
          net4 = "10.${lib.concatMapStringsSep "." toString netAddr}";
          net6 = "feb0:${lib.concatMapStrings lib.toHexString netAddr}:";
        in
        {
          hostAddress = "${net4}.1";
          localAddress = "${net4}.2";
          hostAddress6 = "${net6}:1";
          localAddress6 = "${net6}:2";
        };
    };

  linuxConfig = lib.optionalAttrs isLinux { containers = config.settei.containers; };

  darwinConfig = lib.optionalAttrs (!isLinux) {
    warnings = lib.optional options.settei.containers.isDefined "settei.containers doesn't do anything on darwin yet";
  };
in
{
  _file = ./containers.nix;

  options.settei.containers = lib.mkOption {
    type = with lib.types; attrsOf (submodule containerModule);
    default = {};
  };

  config = lib.mkMerge [
    linuxConfig
    darwinConfig
  ];
}
