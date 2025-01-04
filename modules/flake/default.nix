{
  nixpkgs,
  darwin,
  home-manager,
}:
{
  _file = ./default.nix;

  imports = [
    (import ./configurations.nix { inherit nixpkgs darwin home-manager; })
  ];
}
