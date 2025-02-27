{
  configurations.darwin.kogata =
    { pkgs, ... }:
    {
      nixpkgs.system = "aarch64-darwin";

      settei.user.config.settei.desktop.enable = true;

      settei.unfree.allowedPackages = [ "teams" ];
      environment.systemPackages = with pkgs; [
        (teams.overrideAttrs { sourceRoot = "Microsoft Teams.app"; })
      ];

      settei.tailscale = {
        ipv4 = "100.102.13.61";
        ipv6 = "fd7a:115c:a1e0::e126:d3d";
      };
    };
}
