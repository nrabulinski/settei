{
  config.systems.darwin.kogata.module = {
    nixpkgs.hostPlatform = "aarch64-darwin";

    settei.user.config.settei.desktop.enable = true;

    settei.tailscale = {
      ipv4 = "100.102.13.61";
      ipv6 = "fd7a:115c:a1e0::e126:d3d";
    };
  };
}
