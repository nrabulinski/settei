# This module is supposed to be a reusable set of options you probably would want to set anyway
#
# Other default options which don't necessairly make sense for other people go into hosts/default.nix
{
  lib,
  config,
  ...
} @ args: {
  _file = ./sane-defaults.nix;

  options.settei.sane-defaults = with lib; {
    enable = mkEnableOption "Personal sane defaults (but they should make sense for anyone)";
    allSshKeys = mkOption {
      type = types.attrsOf types.singleLineStr;
      default = {};
    };
  };

  config = lib.mkIf config.settei.sane-defaults.enable (let
    cfg = config.settei;
    inherit (cfg) username;
    configName = optionName:
      args.configurationName
      or (throw "pass configurationName to module arguments or set ${optionName} yourself");
  in {
    _module.args = {
      username = lib.mkDefault username;
    };

    # https://github.com/NixOS/nixpkgs/issues/254807
    boot.swraid.enable = false;

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
        openssh.authorizedKeys.keys = let
          filteredKeys = let
            configName' = configName "users.users.${username}.openssh.authorizedKeys";
          in
            lib.filterAttrs (name: _: name != configName') cfg.sane-defaults.allSshKeys;
        in
          lib.mkDefault (lib.attrValues filteredKeys);
      };
      groups.${username} = {};
    };

    networking.hostName = lib.mkDefault (configName "networking.hostName");

    nix = {
      settings = {
        experimental-features = ["nix-command" "flakes" "repl-flake" "auto-allocate-uids"];
        trusted-users = lib.optionals (!config.security.sudo.wheelNeedsPassword) [username];
        auto-allocate-uids = true;
        extra-substituters = [
          "https://hyprland.cachix.org"
          "https://cache.garnix.io"
          "https://nix-community.cachix.org"
        ];
        trusted-public-keys = [
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
          "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };
    };

    # TODO: Actually this should be extraRules which makes wheel users without any password set
    #       be able to use sudo with no password
    security.sudo.wheelNeedsPassword = false;

    system.stateVersion = "22.05";
  });
}
