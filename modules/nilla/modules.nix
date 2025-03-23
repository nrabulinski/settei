{ lib }:
{
  options = {
    nixosModules = lib.options.create {
      type = lib.types.attrs.of lib.types.raw;
      default.value = { };
    };
    darwinModules = lib.options.create {
      type = lib.types.attrs.of lib.types.raw;
      default.value = { };
    };
    homeModules = lib.options.create {
      type = lib.types.attrs.of lib.types.raw;
      default.value = { };
    };
  };
}
