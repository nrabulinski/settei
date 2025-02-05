{
  configurations.nixos.kazuki =
    {
      modulesPath,
      ...
    }:
    {
      imports = [
        "${modulesPath}/profiles/qemu-guest.nix"
        ./disks.nix

        ./conduit.nix
        ./mail.nix
        ./vault.nix
        ./storage.nix
        ./ntfy.nix
        ./zitadel.nix
        ./prometheus.nix
      ];

      nixpkgs.hostPlatform = "aarch64-linux";
      # Not intended for interactive use
      settei.user.enable = false;

      settei.tailscale = {
        ipv4 = "100.88.21.71";
        ipv6 = "fd7a:115c:a1e0:ab12:4843:cd96:6258:1547";
      };

      boot = {
        loader.systemd-boot.enable = true;
        loader.systemd-boot.configurationLimit = 1;
        loader.efi.canTouchEfiVariables = true;
      };
      systemd.network.enable = true;
      systemd.network.networks."10-wan" = {
        matchConfig.Name = "enp1s0";
        networkConfig.DHCP = "ipv4";
        address = [ "2a01:4f8:c012:e5c::/64" ];
        routes = [ { Gateway = "fe80::1"; } ];
      };
      networking.useNetworkd = true;
    };
}
