{ config, lib }:
{
  options = {
    configBuilders = {
      nixos = lib.options.create {
        type = lib.types.function lib.types.raw;
        default.value = _name: config.inputs.nixpkgs.result.lib.nixosSystem;
      };
      darwin = lib.options.create {
        type = lib.types.function lib.types.raw;
        default.value = _name: config.inputs.darwin.result.lib.darwinSystem;
      };
      home = lib.options.create {
        type = lib.types.function lib.types.raw;
        default.value = _name: config.inputs.home-manager.result.lib.homeManagerConfiguration;
      };
    };

    configurations = {
      nixos = lib.options.create {
        type = lib.types.attrs.lazy lib.types.raw;
        default.value = { };
      };
      darwin = lib.options.create {
        type = lib.types.attrs.lazy lib.types.raw;
        default.value = { };
      };
      home = lib.options.create {
        type = lib.types.attrs.lazy lib.types.raw;
        default.value = { };
      };
    };

    nixosConfigurations = lib.options.create {
      type = lib.types.attrs.lazy lib.types.raw;
      default.value = builtins.mapAttrs config.configBuilders.nixos config.configurations.nixos;
    };
    darwinConfigurations = lib.options.create {
      type = lib.types.attrs.lazy lib.types.raw;
      default.value = builtins.mapAttrs config.configBuilders.darwin config.configurations.darwin;
    };
    homeConfigurations = lib.options.create {
      type = lib.types.attrs.lazy lib.types.raw;
      default.value = builtins.mapAttrs config.configBuilders.home config.configurations.home;
    };
  };
}
