{
  config.systems.nixos.ude.module =
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
      ];

      nixpkgs.hostPlatform = "aarch64-linux";

      boot = {
        loader.systemd-boot.enable = true;
        loader.systemd-boot.configurationLimit = 1;
        loader.efi.canTouchEfiVariables = true;
      };

      settei.tailscale = {
        ipv4 = "100.118.42.139";
        ipv6 = "fd7a:115c:a1e0:ab12:4843:cd96:6276:2a8b";
      };

      settei.incus.enable = true;
      virtualisation.podman.enable = true;

      services.nginx = {
        enable = true;
        appendHttpConfig = ''
          include /impure/nginx/*.conf;
        '';
      };
      networking.firewall.allowedTCPPorts = [ 80 ];

      age.secrets.deluge-auth = {
        file = ../../secrets/ude-deluge.age;
        owner = config.services.deluge.user;
      };
      services.deluge = {
        enable = true;
        web.enable = true;
        declarative = true;
        openFirewall = true;
        authFile = config.age.secrets.deluge-auth.path;
        config = {
          download_location = "${config.services.deluge.dataDir}/torrents/";
          allow_remote = true;
          daemon_port = 58846;
          listen_ports = lib.genList (off: 6881 + off) 10;
          random_port = false;
        };
      };
    };
}
