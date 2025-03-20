# Copy of modules/system/unfree.nix
args@{ config, lib, ... }:
{
  _file = ./unfree.nix;

  options = {
    settei.unfree.allowedPackages =
      with lib;
      mkOption {
        type = types.listOf types.str;
      };
  };

  config = lib.mkIf (!args ? osConfig) {
    nixpkgs.config.allowUnfreePredicate = lib.mkForce (
      pkg: builtins.elem (lib.getName pkg) config.settei.unfree.allowedPackages
    );
  };
}
