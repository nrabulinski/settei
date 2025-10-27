{ isLinux }:
{
  config,
  lib,
  inputs',
  ...
}:
let
  inherit (lib) mkOption types;

  cfg = config.settei.ddns;

  linuxConfig = lib.optionalAttrs isLinux {
    systemd.timers.settei-ddns-client = {
      wantedBy = [ "timers.target" ];
      timerConfig.OnCalendar = "Mon..Sun *-*-* 2:00:00";
      timerConfig.Unit = "settei-ddns-client.service";
    };

    systemd.services.settei-ddns-client = {
      serviceConfig.Type = "oneshot";
      serviceConfig.ExecStart = lib.getExe' inputs'.settei.packages.ddns "client";
      environment = {
        DOMAIN = cfg.domain;
        DDNS_URL = cfg.server;
        SECRET_PATH = cfg.secret;
      };
    };
  };

  darwinConfig = lib.optionalAttrs (!isLinux) {
    assertions = [
      {
        assertion = !cfg.enable;
        message = "settei.ddns doesn't support Darwin yet";
      }
    ];
  };
in
{
  _file = ./ddns.nix;

  options.settei.ddns = {
    enable = lib.mkEnableOption "my scuffed DDNS client";
    server = mkOption {
      type = types.str;
      default = "https://ddns.rab.lol/";
    };
    domain = mkOption {
      type = types.str;
      default = "${config.networking.hostName}.pub.rab.lol";
    };
    secret = mkOption {
      type = types.path;
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      linuxConfig
      darwinConfig
    ]
  );
}
