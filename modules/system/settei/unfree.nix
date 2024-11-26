{ config, lib, ... }:
{
  _file = ./unfree.nix;

  options = {
    # TODO(maybe?): Allow other types and more customizability
    settei.unfree.allowedPackages =
      with lib;
      mkOption {
        type = types.listOf types.str;
      };
  };

  config = {
    nixpkgs.config.allowUnfreePredicate = lib.mkForce (
      pkg: builtins.elem (lib.getName pkg) config.settei.unfree.allowedPackages
    );
  };
}
