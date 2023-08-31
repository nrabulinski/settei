{
  nixpkgs,
  darwin,
  home-manager,
}: {
  config,
  lib,
  flake-parts-lib,
  ...
}: let
  inherit (lib) mkOption mapAttrs;
  inherit (flake-parts-lib) mkSubmoduleOptions;
in {
  _file = ./configurations.nix;

  options = {
    # Those functions take the final arguments and emit a valid configuration.
    # Probably should hardly ever be overriden
    builders = {
      nixos = mkOption {
        type = lib.types.functionTo lib.types.unspecified;
        default = _name: nixpkgs.lib.nixosSystem;
      };
      darwin = mkOption {
        type = lib.types.functionTo lib.types.unspecified;
        default = _name: darwin.lib.darwinSystem;
      };
      home = mkOption {
        type = lib.types.functionTo lib.types.unspecified;
        default = _name: home-manager.lib.homeManagerConfiguration;
      };
    };

    configurations = {
      nixos = mkOption {
        type = lib.types.unspecified;
        default = {};
      };
      darwin = mkOption {
        type = lib.types.unspecified;
        default = {};
      };
      home = mkOption {
        type = lib.types.unspecified;
        default = {};
      };
    };
  };

  config.
    flake = {
    nixosConfigurations =
      mapAttrs
      config.builders.nixos
      config.configurations.nixos;
    darwinConfigurations =
      mapAttrs
      config.builders.darwin
      config.configurations.darwin;
    homeConfigurations =
      mapAttrs
      config.builders.home
      config.configurations.home;
  };
}
