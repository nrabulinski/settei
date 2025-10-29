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
    # Add inputs argument so modules can conveniently use it
    config.__module__.args.dynamic.inputs = builtins.mapAttrs (
      _name: input: input.result
    ) config.inputs;

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
        agenix = mkPackageFlakeOutput { input = "agenix"; };
        base-packages = mkPackage (
          { symlinkJoin, system }:
          symlinkJoin {
            name = "settei-base";
            paths = with (getPkgs system); [
              helix
              fish
              git-commit-last
              git-fixup
              nh
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
        __allPackages =
          let
            all-packages = builtins.attrValues (
              builtins.removeAttrs config.packages [
                "ci-check"
                "__allPackages"
                "ci-build"
              ]
            );
            all-packages' = lib.lists.flatten (map (pkg: builtins.attrValues pkg.result) all-packages);

            nixos-systems = builtins.attrValues config.systems.nixos;
            nixos-systems' = map (system: system.result.config.system.build.toplevel) nixos-systems;

            darwin-systems = builtins.attrValues config.systems.darwin;
            darwin-systems' = map (system: system.result.config.system.build.toplevel) darwin-systems;

            all-drvs = all-packages' ++ nixos-systems' ++ darwin-systems';
            all-drvs' = builtins.concatStringsSep "\n" all-drvs;
          in
          mkPackage (
            { runCommand }:
            runCommand "eval-check" {
              allDerivations = all-drvs';
              passAsFile = [ "allDerivations" ];
            } "touch $out"
          );
        ci-check = mkPackage (
          {
            writeShellScript,
            lib,
            system,
          }:
          writeShellScript "ci-check" ''
            nix-instantiate --strict --eval -E 'import ./nilla.nix {}' -A packages.__allPackages.result.${system}.outPath "$@"
            "${lib.getExe config.packages.formatter.result.${system}}" --ci
          ''
        );
        ci-build = mkPackage (
          { stdenv, runCommand }:
          let
            all-packages = builtins.attrValues (
              builtins.removeAttrs config.packages [
                "ci-check"
                "__allPackages"
                "ci-build"
                # TODO: Build for all systems
                # This is fine because it will be built as part of the system config,
                # but for some reason it doesn't build on x86_64-linux
                "conduit-next"
              ]
            );
            all-packages' = map (pkg: pkg.result.${stdenv.system}) all-packages;

            systems = builtins.attrValues (
              if stdenv.isLinux then config.systems.nixos else config.systems.darwin
            );
            systems' = builtins.filter (
              system: system.result.config.nixpkgs.hostPlatform == stdenv.system
            ) systems;
            systems'' = map (system: system.result.config.system.build.toplevel) systems';

            all-drvs = all-packages' ++ systems'';
          in
          runCommand "ci-build"
            {
              allDerivations = all-drvs;
              passAsFile = [ "allDerivations" ];
            }
            ''
              cp "$allDerivationsPath" "$out"
            ''
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
          mkShell,
          system,
          rustc,
          cargo,
          rustfmt,
          clippy,
          rust-analyzer,
        }:
        mkShell {
          packages = [
            config.packages.agenix.result.${system}
            config.packages.attic-client.result.${system}
            config.packages.nh.result.${system}
            config.packages.formatter.result.${system}

            rustc
            cargo
            rustfmt
            clippy
            rust-analyzer
          ];
        };
    };
  }
)
