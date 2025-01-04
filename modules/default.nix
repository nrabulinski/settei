{
  inputs,
  ...
}:
let
  flakeModule = import ./flake { inherit (inputs) nixpkgs darwin home-manager; };
in
{
  imports = [
    ./system
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
}
