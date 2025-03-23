{
  inputs ? import ./inputs.nix,
}:
(import inputs.nilla).create (
  { config, lib }:
  {
    includes = [
      ./modules/nilla
      ./pkgs
    ];

    config.inputs = builtins.mapAttrs (_: src: {
      inherit src;
      loader = "raw";
    }) inputs;

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
        getPkgs = system: builtins.mapAttrs (_: pkg: pkg.result.${system}) config.packages;
      in
      {
        # Re-export for convenience and for caching
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
          { symlinkJoin, system }:
          symlinkJoin {
            name = "settei-base";
            paths = with (getPkgs system); [
              # TODO: wrappers
              # helix
              # fish
              git-commit-last
              git-fixup
            ];
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
          system,
          nh,
        }:
        mkShellNoCC {
          packages = [
            config.packages.agenix.result.${system}
            config.packages.attic-client.result.${system}
            nh
          ];
        };
    };
  }
)
