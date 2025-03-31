{ lib, config }:
let
  systems = [
    "x86_64-linux"
    "aarch64-linux"
    "aarch64-darwin"
  ];
  transpose =
    attrs: lib.attrs.generate systems (system: builtins.mapAttrs (_: pkg: pkg.result.${system}) attrs);
in
{
  options.flake = lib.options.create {
    type = lib.types.attrs.of lib.types.raw;
  };

  config.flake = {
    inherit (config)
      nixosModules
      darwinModules
      homeModules
      nixosConfigurations
      darwinConfigurations
      homeConfigurations
      ;

    devShells = transpose config.shells;
    packages = transpose config.packages;

    formatter = config.packages.formatter.result;
  };
}
