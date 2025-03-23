{
  inputs ? import ./inputs.nix,
}:
(import inputs.nilla).create (
  { config, lib }:
  {
    config.inputs = builtins.mapAttrs (_: src: {
      inherit src;
      loader = "raw";
    }) inputs;

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
          inputs.nixpkgs.legacyPackages.${system}.callPackage pkg.package (
            {
              self' = builtins.mapAttrs (_: pkg: pkg.result.${system}) config.packages;
            }
            // pkg.settings.args
          )
        );
    };

    config.builders.custom-load = {
      settings.type = lib.types.submodule {
        options.args = lib.options.create {
          type = lib.types.null;
          default.value = null;
        };
      };
      settings.default = { };
      build = pkg: lib.attrs.generate pkg.systems (system: pkg.package { inherit system; });
    };

    config.packages =
      let
        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
        ];
        mkPackage = package: {
          builder = "nixpkgs-flake";
          inherit systems package;
        };
        mkPackageFlakeOutput =
          {
            input,
            output ? input,
          }:
          {
            inherit systems;
            builder = "custom-load";
            package = { system }: inputs.${input}.packages.${system}.${output};
          };
      in
      {
        attic-client = mkPackageFlakeOutput {
          input = "attic";
          output = "attic-client";
        };
        attic-server = mkPackageFlakeOutput {
          input = "attic";
          output = "attic-server";
        };
        agenix = mkPackageFlakeOutput { input = "agenix"; };
        base-packages = mkPackage (
          { symlinkJoin }:
          symlinkJoin {
            name = "settei-base";
            paths = [ ];
          }
        );
      };

    config.shells.default = {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      builder = "nixpkgs-flake";
      shell =
        {
          mkShellNoCC,
          nh,
          self',
        }:
        mkShellNoCC {
          packages = [
            self'.agenix
            self'.attic-client
            nh
          ];
        };
    };
  }
)
