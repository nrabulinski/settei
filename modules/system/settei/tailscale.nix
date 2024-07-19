{ isLinux }:
{ config, lib, ... }:
let
  inherit (lib)
    types
    mkEnableOption
    mkIf
    mkOption
    ;

  cfg = config.settei.tailscale;

  options.settei.tailscale = {
    enable = mkEnableOption "Tailscale configuration";
    tailnet = mkOption { type = types.str; };
    ipv4 = mkOption { type = types.str; };
    ipv6 = mkOption { type = types.str; };
  };

  sharedConfig = {
    services.tailscale.enable = true;
  };

  nmEnabled = config.networking.networkmanager.enable;
  linuxConfig = lib.optionalAttrs isLinux (
    lib.mkMerge [
      {
        networking.firewall.trustedInterfaces = [ "tailscale0" ];

      }
      (mkIf (!nmEnabled) {
        # When NetworkManager isn't in use, add tailscale DNS address manually
        networking.nameservers = [
          "100.100.100.100"
          "1.1.1.1"
          "1.0.0.1"
        ];
        networking.search = [ cfg.tailnet ];
      })
    ]
  );
in
{
  _file = ./tailscale.nix;

  inherit options;

  config = mkIf cfg.enable (
    lib.mkMerge [
      sharedConfig
      linuxConfig
    ]
  );
}
