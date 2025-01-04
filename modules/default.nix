{
  imports = [
    ./system
    ./flake
  ];

  flake.homeModules = rec {
    settei = ./home;
    default = settei;
  };
}
