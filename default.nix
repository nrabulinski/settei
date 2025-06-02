let
  nilla = import ./nilla.nix { };
  getPackage = name: nilla.packages.${name}.result.${builtins.currentSystem};
in
{
  ci.check = getPackage "ci-check";
  formatter = getPackage "formatter";
  systems = {
    nixos = builtins.mapAttrs (_: system: system.result) nilla.systems.nixos;
    darwin = builtins.mapAttrs (_: system: system.result) nilla.systems.darwin;
  };
}
