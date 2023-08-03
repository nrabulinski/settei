{
  flake-parts-lib,
  lib,
  inputs,
  ...
}: let
  inherit (flake-parts-lib) importApply;
  flakeModules = {
    configurations = importApply ./configurations.nix {inherit (inputs) nixpkgs darwin home-manager;};
  };
in {
  imports = lib.attrValues flakeModules;

  flake = {inherit flakeModules;};
}
