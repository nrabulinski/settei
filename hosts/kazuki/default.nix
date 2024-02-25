{
  configurations.nixos.kazuki =
    {
      config,
      modulesPath,
      lib,
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
        ./attic.nix
        ./ntfy.nix
      ];

      nixpkgs.hostPlatform = "aarch64-linux";
      # Not intended for interactive use
      settei.user.enable = false;

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
        routes = [ { routeConfig.Gateway = "fe80::1"; } ];
      };
      networking.useNetworkd = true;

      common.hercules.enable = true;
      common.github-runner = {
        enable = true;
        runners.settei = {
          url = "https://github.com/nrabulinski/settei";
          instances = 2;
        };
      };
    };
}
