{ isLinux }:
{ config, lib, ... }@args:
let
  cfg = config.settei.sane-defaults;
  inherit (config.settei) username;

  options = {
    settei.sane-defaults = with lib; {
      enable = mkEnableOption "Personal sane defaults (but they should make sense for anyone)";
      allSshKeys = mkOption {
        type = types.attrsOf types.singleLineStr;
        default = { };
      };
    };
  };

  sharedConfig =
    let
      adminNeedsPassword = isLinux -> config.security.sudo.wheelNeedsPassword;
    in
    {
      _module.args = {
        username = lib.mkDefault username;
      };

      networking.hostName = lib.mkDefault (
        args.configurationName
          or (throw "pass configurationName to module arguments or set networking.hostName yourself")
      );

      # Flakes are unusable without git present so pull it into the environment by default
      settei.user.config.programs.git.enable = lib.mkDefault true;

      # FIXME: Move to common
      users.users.${username}.openssh.authorizedKeys.keys =
        let
          configName' =
            args.configurationName
              or (throw "pass configurationName to module arguments or set users.users.${username}.openssh.authorizedKeys yourself");
          filteredKeys = lib.filterAttrs (name: _: name != configName') cfg.allSshKeys;
        in
        lib.mkDefault (lib.attrValues filteredKeys);

      nix = {
        settings = {
          experimental-features = [
            "nix-command"
            "flakes"
            "repl-flake"
            "auto-allocate-uids"
          ];
          trusted-users = lib.optionals (!adminNeedsPassword) [ username ];
          use-xdg-base-directories = true;
          auto-allocate-uids = true;
          extra-substituters = [
            "https://hyprland.cachix.org"
            "https://cache.garnix.io"
            "https://nix-community.cachix.org"
            "https://hercules-ci.cachix.org"
            "https://nrabulinski.cachix.org"
            "https://cache.nrab.lol"
          ];
          extra-trusted-public-keys = [
            "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
            "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "hercules-ci.cachix.org-1:ZZeDl9Va+xe9j+KqdzoBZMFJHVQ42Uu/c/1/KMC5Lw0="
            "nrabulinski.cachix.org-1:Q5FD7+1c68uH74CQK66UWNzxhanZW8xcg1LFXxGK8ic="
            "cache.nrab.lol-1:CJl1TouOyuJ1Xh4tZSXLwm3Upt06HzUNZmeyuEB9EZg="
          ];
        };
      };
    };

  linuxConfig = lib.optionalAttrs isLinux {
    hardware.enableRedistributableFirmware = true;

    services.openssh.enable = true;
    programs.mosh.enable = lib.mkDefault true;
    programs.git.enable = lib.mkDefault true;

    users = {
      mutableUsers = false;
      users.${username} = {
        isNormalUser = true;
        home = "/home/${username}";
        group = username;
        extraGroups = [ "wheel" ];
      };
      groups.${username} = { };
    };

    # TODO: Actually this should be extraRules which makes wheel users without any password set
    #       be able to use sudo with no password
    security.sudo.wheelNeedsPassword = false;
  };

  darwinConfig = lib.optionalAttrs (!isLinux) {
    services.nix-daemon.enable = true;

    security.pam.enableSudoTouchIdAuth = true;

    users.users.${username}.home = "/Users/${username}";
  };
in
{
  _file = ./sane-defaults.nix;

  inherit options;

  config = lib.mkIf config.settei.sane-defaults.enable (
    lib.mkMerge [
      sharedConfig
      linuxConfig
      darwinConfig
    ]
  );
}
