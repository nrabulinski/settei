{
  inputs ? import ./inputs.nix,
}:
(import inputs.nilla).create (
  { lib }:
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
          system: inputs.nixpkgs.legacyPackages.${system}.callPackage pkg.package pkg.settings.args
        );
    };

    config.shells.default = {
      systems = [ "x86_64-linux" ];
      builder = "nixpkgs-flake";
      shell =
        { mkShell, hello }:
        mkShell {
          packages = [ hello ];
        };
    };
  }
)
