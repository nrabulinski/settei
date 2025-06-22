{ isLinux }:
{
  config,
  pkgs,
  lib,
  ...
}@args:
let
  cfg = config.settei.sane-defaults;
  inherit (config.settei) username;

  options = {
    settei.sane-defaults = with lib; {
      enable = mkEnableOption "Personal sane defaults (but they should make sense for anyone)" // {
        default = true;
      };
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
            "auto-allocate-uids"
          ];
          trusted-users = lib.optionals (!adminNeedsPassword) [ username ];
          use-xdg-base-directories = true;
          auto-allocate-uids = true;
          allow-import-from-derivation = false;
          extra-substituters = [
            "https://cache.nrab.lol"
            "https://cache.garnix.io"
            "https://nix-community.cachix.org"
            "https://nrabulinski.cachix.org"
          ];
          extra-trusted-public-keys = [
            "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
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
        extraGroups = lib.mkMerge [
          [ "wheel" ]
          (lib.mkIf config.networking.networkmanager.enable [ "networkmanager" ])
        ];
      };
      groups.${username} = { };
    };

    # TODO: Actually this should be extraRules which makes wheel users without any password set
    #       be able to use sudo with no password
    security.sudo.wheelNeedsPassword = false;

    system.stateVersion = "22.05";

    # https://github.com/NixOS/nixpkgs/issues/254807
    boot.swraid.enable = false;

    i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
    boot.kernel.sysctl."kernel.yama.ptrace_scope" = 0;

    settei.user.config.services.ssh-agent.enable = true;

    nix.settings = {
      experimental-features = [ "cgroups" ];
      use-cgroups = true;
    };
    systemd.services.nix-daemon.serviceConfig = {
      Delegate = "yes";
      DelegateSubgroup = "supervisor";
    };
  };

  darwinConfig = lib.optionalAttrs (!isLinux) {
    system.stateVersion = 4;
    # FIXME: Remove
    system.primaryUser = username;

    security.pam.services.sudo_local.touchIdAuth = true;

    users.users.${username}.home = "/Users/${username}";
    # Every macOS ARM machine can emulate x86.
    nix.settings.extra-platforms = lib.mkIf pkgs.stdenv.isAarch64 [ "x86_64-darwin" ];
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
