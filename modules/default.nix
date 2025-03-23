{
  config,
  inputs,
  ...
}:
{
  flake.homeModules = rec {
    settei = ./home;
    default = settei;
  };

  flake.nixosModules = rec {
    settei = import ./system {
      inherit (config) perInput;
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

  flake.darwinModules = rec {
    settei = import ./system {
      inherit (config) perInput;
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
