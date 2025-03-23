{
  config,
  lib,
}:
{
  config.builders.nixpkgs-flake = {
    settings.type = lib.types.submodule {
      options.args = lib.options.create {
        type = lib.types.any;
        default.value = { };
      };
    };
    settings.default = { };
    build =
      pkg:
      lib.attrs.generate pkg.systems (
        system:
        config.inputs.nixpkgs.result.legacyPackages.${system}.callPackage pkg.package (
          {
            self' = builtins.mapAttrs (_: pkg: pkg.result.${system}) config.packages;
          }
          // pkg.settings.args
        )
      );
  };
}
