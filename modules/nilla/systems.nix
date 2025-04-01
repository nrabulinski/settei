{ config, lib }:
let
  mkBuilderOption =
    typ:
    lib.options.create {
      type = lib.types.function (lib.types.function lib.types.raw);
      default.value = _name: _module: throw "Builder for systems.${typ} is not implemented";
    };
  inherit (config.systems) builders;
  mkSystemModule =
    typ:
    { config, name }:
    {
      options = {
        name = lib.options.create {
          type = lib.types.string;
          default.value = name;
        };
        module = lib.options.create {
          type = lib.types.raw;
          default.value = { };
        };
        builder = lib.options.create {
          type = lib.types.function (lib.types.function lib.types.raw);
          default.value = builders.${typ};
        };
        result = lib.options.create {
          type = lib.types.raw;
          writable = false;
          default.value = config.builder config.name config.module;
        };
      };
    };
  mkSystemOption =
    typ:
    lib.options.create {
      type = lib.types.attrs.of (lib.types.submodule (mkSystemModule typ));
      default.value = { };
    };
in
{
  options = {
    systems = {
      builders.nixos = mkBuilderOption "nixos";
      builders.darwin = mkBuilderOption "darwin";
      builders.home = mkBuilderOption "home";
      nixos = mkSystemOption "nixos";
      darwin = mkSystemOption "darwin";
      home = mkSystemOption "home";
    };
  };
}
