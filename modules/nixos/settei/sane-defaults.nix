{
  lib,
  config,
  ...
} @ args: {
  _file = ./sane-defaults.nix;

  options.settei.sane-defaults = {
    enable = lib.mkEnableOption "Personal sane defaults";
  };

  config = lib.mkIf config.settei.sane-defaults.enable (let
    cfg = config.settei;
    inherit (cfg) username;
  in {
    _module.args = {
      username = lib.mkDefault username;
    };

    hardware.enableRedistributableFirmware = true;

    services.openssh.enable = true;
    services.tailscale.enable = true;
    programs.mosh.enable = lib.mkDefault true;

    users = {
      mutableUsers = false;
      users.${username} = {
        isNormalUser = true;
        home = "/home/${username}";
        group = username;
        extraGroups = ["wheel"];
      };
      groups.${username} = {};
    };

    networking.hostName = lib.mkDefault (
      args.configurationName
      or (throw "pass configurationName to module arguments or set networking.hostName yourself")
    );
    time.timeZone = lib.mkDefault "Europe/Warsaw";

    nix = {
      settings = {
        experimental-features = ["nix-command" "flakes" "repl-flake" "auto-allocate-uids"];
        trusted-users = [username];
        auto-allocate-uids = true;
      };
    };

    # TODO: Actually this should be extraRules which makes wheel users without any password set
    #       be able to use sudo with no password
    security.sudo.wheelNeedsPassword = false;

    system.stateVersion = "22.05";
  });
}
