{
  config,
  inputs,
}:
let
  perInput = system: flake: {
    packages = flake.packages.${system};
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
        inputs.attic.nixosModules.atticd
        inputs.lix-module.nixosModules.default
        {
          disabledModules = [
            "services/networking/atticd.nix"
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
        inputs.lix-module.nixosModules.default
      ];
    };
    default = combined;
  };
}
