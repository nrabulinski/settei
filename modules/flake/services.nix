# List of features I want this module to eventually have
# TODO: Automatic port allocation
# TODO: Making it possible to conveniently isolate services (running them in NixOS containers)
# TODO: Handling specializations
# TODO: Convenient http handling
# TODO: Automatic backup
{ config, lib, ... }:
let
  serviceModule =
    { config, ... }:
    {
      options = {
        host = lib.mkOption {
          type = lib.types.str;
        };
        ports = lib.mkOption {
          type = with lib.types; listOf port;
          default = [ ];
        };
        hosts = lib.mkOption {
          type = with lib.types; listOf str;
          default = [ config.host ];
        };
        config = lib.mkOption {
          type = lib.types.deferredModule;
          default = { };
        };
        hostConfig = lib.mkOption {
          type = with lib.types; attrsOf deferredModule;
          default = { };
        };
      };
    };

  moduleToHostConfigs =
    cfg:
    lib.genAttrs cfg.hosts (host: {
      imports = [
        cfg.config
        (cfg.hostConfig.${host} or { })
      ];
    });

  maybeGetPreviousConfigs = acc: host: (acc.${host} or { imports = [ ]; }).imports;
in
{
  _file = ./services.nix;

  options = {
    services = lib.mkOption {
      type = with lib.types; attrsOf (submodule serviceModule);
      default = { };
    };

    __extraHostConfigs = lib.mkOption {
      type = with lib.types; attrsOf deferredModule;
      readOnly = true;
    };
  };

  config.__extraHostConfigs =
    let
      duplicatePorts = lib.pipe config.services [
        lib.attrValues
        (map (cfg: cfg.ports))
        lib.flatten
        (lib.groupBy' (cnt: _: cnt + 1) 0 toString)
        (lib.filterAttrs (_: cnt: cnt > 1))
        lib.attrNames
      ];
      assertMsg =
        let
          plural = lib.length duplicatePorts > 1;
        in
        "\nBad service config:\nThe following port${if plural then "s" else ""} ${
          if plural then "were" else "was"
        } declared multiple times: ${lib.concatStringsSep ", " duplicatePorts}";
      # Here I collect all the services.<name>.config into a flat
      # __extraHostConfigs.<host>.imports = [
      #   ...
      # ]
      # so that I can easily import them in hosts/default.nix
      hostConfigs = lib.pipe config.services [
        lib.attrValues
        (lib.foldl' (
          acc: cfg:
          acc
          // lib.mapAttrs (host: c: {
            imports = c.imports ++ (maybeGetPreviousConfigs acc host);
          }) (moduleToHostConfigs cfg)
        ) { })
      ];
    in
    if duplicatePorts != [ ] then throw assertMsg else hostConfigs;
}
