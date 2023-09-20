{config, ...}: {
  flake.darwinModules = {
    settei = import ./settei {inherit (config) perInput;};
  };
}
