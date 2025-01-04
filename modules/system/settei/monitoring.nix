{ isLinux }:
{ lib, ... }:
let
  linuxConfig = lib.optionalAttrs isLinux {
    services.prometheus.exporters.node = {
      enable = true;
      enabledCollectors = [ "systemd" ];
    };
  };

  darwinConfig = lib.optionalAttrs (!isLinux) { };
in
{
  _file = ./monitoring.nix;

  config = lib.mkMerge [
    linuxConfig
    darwinConfig
  ];
}
