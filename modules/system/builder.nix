{ isLinux }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.settei.remote-builder;

  sharedConfig = {
    users.users.${cfg.user} = {
      shell = pkgs.bash;
      openssh.authorizedKeys.keys = cfg.sshKeys;
    };

    nix.settings.trusted-users = [ cfg.user ];
  };

  linuxConfig = lib.optionalAttrs isLinux {
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.user;
    };
    users.groups.${cfg.user} = { };
  };

  mergedConfig = lib.mkMerge [
    sharedConfig
    linuxConfig
  ];
in
{
  _file = ./builder.nix;

  options.settei.remote-builder = {
    enable = lib.mkEnableOption "configuring this machine as a remote builder";
    user = lib.mkOption {
      type = lib.types.str;
      default = "nixremote";
    };
    sshKeys = lib.mkOption {
      type = lib.types.listOf lib.types.singleLineStr;
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable mergedConfig;
}
