{
  config,
  inputs,
}:
let
  perInput = system: flake: {
    packages = flake.packages.${system};
  };
  # Tests on macOS with auto-allocate-uids are currently broken.
  # Revert once fixes are found and merged.
  no-lix-install-checks =
    { lib, ... }:
    {
      nixpkgs.overlays = lib.mkAfter [
        (_final: prev: {
          lix = prev.lix.overrideAttrs {
            doInstallCheck = false;
            # TODO: Those shouldn't be affected...
            doCheck = false;
          };
        })
      ];
    };
in
{
  config.homeModules = rec {
    settei = ./home;
    default = settei;
  };

  config.nixosModules = rec {
    settei = import ./system {
      inherit perInput;
      isLinux = true;
    };
    combined = {
      imports = [
        settei
        inputs.agenix.nixosModules.age
        inputs.disko.nixosModules.disko
        inputs.mailserver.nixosModules.default
        inputs.home-manager.nixosModules.home-manager
        "${inputs.attic}/nixos/atticd.nix"
        inputs.lix-module.nixosModules.default
        no-lix-install-checks
        {
          disabledModules = [
            "services/networking/atticd.nix"
          ];
          services.atticd.useFlakeCompatOverlay = false;
          nixpkgs.overlays = [
            (final: _: {
              attic-client = config.packages.attic-client.result.${final.system};
              attic-server = config.packages.attic-server.result.${final.system};
            })
          ];
        }
      ];
    };
    default = combined;
  };

  config.darwinModules = rec {
    settei = import ./system {
      inherit perInput;
      isLinux = false;
    };
    combined = {
      imports = [
        settei
        inputs.agenix.darwinModules.age
        inputs.home-manager.darwinModules.home-manager
        inputs.lix-module.darwinModules.default
        no-lix-install-checks
      ];
    };
    default = combined;
  };
}
