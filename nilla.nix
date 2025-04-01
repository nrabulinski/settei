{
  inputs ? import ./inputs.nix,
}:
(import inputs.nilla).create (
  { config, lib }:
  {
    includes = [
      ./modules/nilla
      ./pkgs
      ./wrappers
      ./hosts
      ./assets
      ./services
      ./modules
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
              helix
              fish
              git-commit-last
              git-fixup
            ];
          }
        );
        formatter = {
          inherit systems;
          builder = "custom-load";
          package =
            { system }:
            let
              eval = inputs.treefmt.lib.evalModule inputs.nixpkgs.legacyPackages.${system} ./treefmt.nix;
            in
            eval.config.build.wrapper;
        };
        ci-check =
          let
            all-packages = builtins.attrValues (builtins.removeAttrs config.packages [ "ci-check" ]);
            all-packages' = lib.lists.flatten (map (pkg: builtins.attrValues pkg.result) all-packages);

            nixos-systems = builtins.attrValues config.systems.nixos;
            nixos-systems' = map (system: system.result.config.system.build.toplevel) nixos-systems;

            darwin-systems = builtins.attrValues config.systems.darwin;
            darwin-systems' = map (system: system.result.config.system.build.toplevel) darwin-systems;

            all-drvs = all-packages' ++ nixos-systems' ++ darwin-systems';
            all-drvs' = lib.strings.concatMapSep "\n" builtins.unsafeDiscardStringContext all-drvs;
          in
          mkPackage (
            {
              lib,
              stdenvNoCC,
              system,
            }:
            stdenvNoCC.mkDerivation {
              name = "nilla-eval-check";
              src = lib.cleanSource ./.;
              doCheck = true;

              allDerivations = all-drvs';
              formatter = lib.getExe config.packages.formatter.result.${system};

              passAsFile = [ "allDerivations" ];

              installPhase = ''touch "$out"'';
              checkPhase = ''
                "$formatter" --ci
              '';
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
