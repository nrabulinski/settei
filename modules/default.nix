{
  config,
  inputs,
  ...
}:
let
  flakeModule = import ./flake { inherit (inputs) nixpkgs darwin home-manager; };
in
{
  imports = [
    flakeModule
  ];

  flake.homeModules = rec {
    settei = ./home;
    default = settei;
  };

  flake.flakeModules = rec {
    settei = flakeModule;
    default = settei;
  };

  flake.nixosModules = rec {
    settei = import ./system {
      inherit (config) perInput;
      isLinux = true;
    };
    default = settei;
  };

  flake.darwinModules = rec {
    settei = import ./system {
      inherit (config) perInput;
      isLinux = false;
    };
    default = settei;
  };
}
