{isLinux}: {
  config,
  lib,
  ...
}: let
  sharedConfig = {
    settei.programs.podman.enable = true;
  };

  linuxConfig = lib.optionalAttrs isLinux {
    boot.kernel.sysctl."kernel.yama.ptrace_scope" = 0;
  };

  darwinConfig = lib.optionalAttrs (!isLinux) {};

  finalConfig = lib.mkMerge [
    sharedConfig
    linuxConfig
    darwinConfig
  ];
in {
  _file = ./user.nix;

  config = lib.mkIf config.settei.user.enable finalConfig;
}
