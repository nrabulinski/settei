# For sane-default options shared between NixOS and darwin, see modules/shared/settei/sane-defaults.nix
{
  config,
  username,
  lib,
  ...
} @ args: let
  cfg = config.settei.sane-defaults;
  nmEnabled = config.networking.networkmanager.enable;
in {
  config = lib.mkIf cfg.enable {
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
        # FIXME: Move to common
        openssh.authorizedKeys.keys = let
          configName' =
            args.configurationName
            or (throw "pass configurationName to module arguments or set users.users.${username}.openssh.authorizedKeys yourself");
          filteredKeys = lib.filterAttrs (name: _: name != configName') cfg.allSshKeys;
        in
          lib.mkDefault (lib.attrValues filteredKeys);
      };
      groups.${username} = {};
    };

    # TODO: Actually this should be extraRules which makes wheel users without any password set
    #       be able to use sudo with no password
    security.sudo.wheelNeedsPassword = false;

    # When NetworkManager isn't in use, add tailscale DNS address manually
    # FIXME: Move to common
    networking = lib.mkIf (!nmEnabled && config.services.tailscale.enable && cfg.tailnet != null) {
      nameservers = [
        "100.100.100.100"
        "1.1.1.1"
        "1.0.0.1"
      ];
      search = [cfg.tailnet];
    };

    # NetworkManager probably means desktop system so we don't want to slow down boot times
    systemd.services = lib.mkIf nmEnabled {
      NetworkManager-wait-online.enable = false;
    };
  };
}
