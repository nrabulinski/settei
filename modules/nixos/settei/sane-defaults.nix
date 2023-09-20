# For sane-default options shared between NixOS and darwin, see modules/shared/settei/sane-defaults.nix
{
  config,
  username,
  lib,
  ...
} @ args: let
  cfg = config.settei.sane-defaults;
in {
  config = lib.mkIf cfg.enable {
    # https://github.com/NixOS/nixpkgs/issues/254807
    boot.swraid.enable = false;

    hardware.enableRedistributableFirmware = true;

    services.openssh.enable = true;
    programs.mosh.enable = lib.mkDefault true;

    users = {
      mutableUsers = false;
      users.${username} = {
        isNormalUser = true;
        home = "/home/${username}";
        group = username;
        extraGroups = ["wheel"];
        openssh.authorizedKeys.keys = let
          filteredKeys = let
            configName' =
              args.configurationName
              or (throw "pass configurationName to module arguments or set users.users.${username}.openssh.authorizedKeys yourself");
          in
            lib.filterAttrs (name: _: name != configName') cfg.allSshKeys;
        in
          lib.mkDefault (lib.attrValues filteredKeys);
      };
      groups.${username} = {};
    };

    # TODO: Actually this should be extraRules which makes wheel users without any password set
    #       be able to use sudo with no password
    security.sudo.wheelNeedsPassword = false;

    system.stateVersion = "22.05";
  };
}
