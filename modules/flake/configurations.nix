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
  possibleConfigurations = {
    nixos = {};
    darwin = {};
    home = {};
  };
in {
  _file = ./configurations.nix;

  options = {
    # Those functions take the final arguments and emit a valid configuration.
    # Probably should hardly ever be overriden
    builders = {
      nixos = mkOption {
        type = lib.types.functionTo lib.types.unspecified;
        default = nixpkgs.lib.nixosSystem;
      };
      darwin = mkOption {
        type = lib.types.functionTo lib.types.unspecified;
        default = darwin.lib.darwinSystem;
      };
      home = mkOption {
        type = lib.types.functionTo lib.types.unspecified;
        default = home-manager.lib.homeManagerConfiguration;
      };
    };

    # Those functions map the value of the configuration attribute
    # and emit a list of arguments to be passed to respected evalModules
    mappers =
      mapAttrs
      (_: _:
        mkOption {
          type = lib.types.functionTo lib.types.attrs;
          default = lib.id;
        })
      possibleConfigurations;

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

    # This is exposed so that it's possible to modify the arguments that get passed to a builder
    # after they have been mapped. Probably shouldn't do it. Probably should remove it or make it read-only
    configurationOptions =
      mapAttrs
      (_: _:
        mkOption {
          type = lib.types.attrsOf lib.types.attrs;
        })
      possibleConfigurations;
  };

  config = {
    configurationOptions =
      mapAttrs
      (
        name: _:
          mapAttrs
          (configurationName: val: let
            mapped = config.mappers.${name} val;
            # TODO: specialArgs is actually extraSpecialArgs in home-manager.
            #       At which level should that be handled?
            defaultArgs = {
              specialArgs = {inherit configurationName;};
            };
          in
            lib.recursiveUpdate defaultArgs mapped)
          config.configurations.${name}
      )
      possibleConfigurations;

    flake = {
      nixosConfigurations =
        mapAttrs
        (_: args: config.builders.nixos args)
        config.configurationOptions.nixos;
    };
  };
}
