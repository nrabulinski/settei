{ lib }:
{
  config.builders.custom-load = {
    settings.type = lib.types.submodule {
      options.args = lib.options.create {
        type = lib.types.null;
        default.value = null;
      };
    };
    settings.default = { };
    build = pkg: lib.attrs.generate pkg.systems (system: pkg.package { inherit system; });
  };
}
