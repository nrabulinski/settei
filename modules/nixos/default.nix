{config, ...}: {
  flake.nixosModules.settei = import ./settei {inherit (config) perInput;};
}
