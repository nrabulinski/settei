{
  config,
  lib,
  inputs,
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
        system: inputs.nixpkgs.legacyPackages.${system}.callPackage pkg.package pkg.settings.args
      );
  };
}
