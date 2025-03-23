{ lib, config }:
let
  inherit (builtins)
    attrNames
    attrValues
    concatStringsSep
    mapAttrs
    foldl'
    groupBy
    length
    ;
  serviceModule =
    { config }:
    {
      options = {
        host = lib.options.create {
          type = lib.types.str;
        };
        ports = lib.options.create {
          type = lib.types.list.of lib.types.port;
          default.value = [ ];
        };
        hosts = lib.options.create {
          type = lib.types.list.of lib.types.str;
          default.value = [ config.host ];
        };
        module = lib.options.create {
          type = lib.types.raw;
          default.value = { };
        };
        hostModule = lib.options.create {
          type = lib.types.attrs.of lib.types.raw;
          default.value = { };
        };
      };
    };

  moduleToHostConfigs =
    cfg:
    lib.attrs.generate cfg.hosts (host: {
      imports = [
        cfg.module
        (cfg.hostModule.${host} or { })
      ];
    });

  maybeGetPreviousConfigs = acc: host: (acc.${host} or { imports = [ ]; }).imports;

  # Copied from nixpkgs/lib/lists.nix
  groupBy' =
    op: nul: pred: lst:
    mapAttrs (_name: foldl' op nul) (groupBy pred lst);
  duplicatePorts = lib.fp.pipe [
    attrValues
    (map (cfg: cfg.ports))
    lib.lists.flatten
    (groupBy' (cnt: _: cnt + 1) 0 toString)
    (lib.attrs.filter (_: cnt: cnt > 1))
    attrNames
  ] config.services;
in
{
  options.services = lib.options.create {
    type = lib.types.attrs.of (lib.types.submodule serviceModule);
    default.value = { };
  };

  options.extraHostConfigs = lib.options.create {
    type = lib.types.attrs.of lib.types.raw;
    writable = false;
    default.value = lib.fp.pipe [
      attrValues
      (foldl' (
        acc: cfg:
        acc
        // mapAttrs (host: c: {
          imports = c.imports ++ (maybeGetPreviousConfigs acc host);
        }) (moduleToHostConfigs cfg)
      ) { })
    ] config.services;
  };

  config.assertions = [
    {
      assertion = duplicatePorts == [ ];
      message =
        let
          plural = length duplicatePorts > 1;
        in
        "\nBad service config:\nThe following port${if plural then "s" else ""} ${
          if plural then "were" else "was"
        } declared multiple times: ${concatStringsSep ", " duplicatePorts}";
    }
  ];
}
