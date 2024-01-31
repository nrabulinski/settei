{isLinux}: {
  _file = ./default.nix;

  imports = [
    (import ./podman.nix {inherit isLinux;})
  ];
}
