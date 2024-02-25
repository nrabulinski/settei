{
  nixpkgs,
  darwin,
  home-manager,
}:
{
  config,
  lib,
  flake-parts-lib,
  ...
}:
with lib;
{
  _file = ./configurations.nix;

  options = {
    # Those functions take the final arguments and emit a valid configuration.
    # Probably should hardly ever be overriden
    builders = {
      nixos = mkOption {
        type = types.functionTo types.unspecified;
        default = _name: nixpkgs.lib.nixosSystem;
      };
      darwin = mkOption {
        type = types.functionTo types.unspecified;
        default = _name: darwin.lib.darwinSystem;
      };
      home = mkOption {
        type = types.functionTo types.unspecified;
        default = _name: home-manager.lib.homeManagerConfiguration;
      };
    };

    configurations = {
      nixos = mkOption {
        type = types.lazyAttrsOf types.deferredModule;
        default = { };
      };
      darwin = mkOption {
        type = types.lazyAttrsOf types.deferredModule;
        default = { };
      };
      home = mkOption {
        type = types.lazyAttrsOf types.deferredModule;
        default = { };
      };
    };
  };

  config.flake = {
    nixosConfigurations = mapAttrs config.builders.nixos config.configurations.nixos;
    darwinConfigurations = mapAttrs config.builders.darwin config.configurations.darwin;
    homeConfigurations = mapAttrs config.builders.home config.configurations.home;
  };
}
