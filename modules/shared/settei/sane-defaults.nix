# This module is supposed to be a reusable set of options you probably would want to set anyway.
# For options specific to nixos or darwin go to modules/{nixos,darwin}/settei/sane-defaults.nix
{
  config,
  pkgs,
  lib,
  ...
} @ args: {
  _file = ./sane-defaults.nix;

  options.settei.sane-defaults = with lib; {
    enable = mkEnableOption "Personal sane defaults (but they should make sense for anyone)";
    allSshKeys = mkOption {
      type = types.attrsOf types.singleLineStr;
      default = {};
    };
    tailnet = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
  };

  config = lib.mkIf config.settei.sane-defaults.enable (let
    cfg = config.settei;
    inherit (cfg) username;
    adminNeedsPassword = pkgs.stdenv.isLinux -> config.security.sudo.wheelNeedsPassword;
  in {
    _module.args = {
      username = lib.mkDefault username;
    };

    services.tailscale.enable = true;

    networking.hostName = lib.mkDefault (
      args.configurationName
      or (throw "pass configurationName to module arguments or set networking.hostName yourself")
    );

    # Flakes are unusable without git present so pull it into the environment by default
    settei.user.config.programs.git.enable = lib.mkDefault true;

    nix = {
      settings = {
        experimental-features = ["nix-command" "flakes" "repl-flake" "auto-allocate-uids"];
        trusted-users = lib.optionals (!adminNeedsPassword) [username];
        auto-allocate-uids = true;
        extra-substituters = [
          "https://hyprland.cachix.org"
          "https://cache.garnix.io"
          "https://nix-community.cachix.org"
          "https://hercules-ci.cachix.org"
          "https://nrabulinski.cachix.org"
        ];
        trusted-public-keys = [
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
          "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "hercules-ci.cachix.org-1:ZZeDl9Va+xe9j+KqdzoBZMFJHVQ42Uu/c/1/KMC5Lw0="
          "nrabulinski.cachix.org-1:Q5FD7+1c68uH74CQK66UWNzxhanZW8xcg1LFXxGK8ic="
        ];
      };
    };
  });
}
