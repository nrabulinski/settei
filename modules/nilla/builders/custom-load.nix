{ lib }:
{
  config.builders.custom-load = {
    settings.type = lib.types.submodule { };
    settings.default = { };
    build = pkg: lib.attrs.generate pkg.systems (system: pkg.package { inherit system; });
  };
}
