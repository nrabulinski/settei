{
  config,
  lib,
  ...
}: {
  flake = lib.genAttrs ["nixosModules" "darwinModules"] (attr: let
    isLinux = lib.hasPrefix "nixos" attr;
  in {
    settei = import ./settei {
      inherit (config) perInput;
      inherit isLinux;
    };
    common = import ./common {
      inherit isLinux;
    };
  });
}
