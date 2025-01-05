{
  config,
  lib,
  username,
  ...
}:
let
  # TODO: Maybe eventually support multi-user
  userAllowedPackages =
    lib.optionals config.settei.user.enable
      config.home-manager.users.${username}.settei.unfree.allowedPackages;
in
{
  _file = ./unfree.nix;

  options = {
    # TODO(maybe?): Allow other types and more customizability
    settei.unfree.allowedPackages =
      with lib;
      mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
  };

  config = {
    nixpkgs.config.allowUnfreePredicate = lib.mkForce (
      pkg: builtins.elem (lib.getName pkg) (config.settei.unfree.allowedPackages ++ userAllowedPackages)
    );
  };
}
