{
  configurations.nixos.ude =
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

      common.hercules.enable = true;
      services.hercules-ci-agent.settings.concurrentTasks = 6;
      common.github-runner = {
        enable = true;
        runners.settei = {
          url = "https://github.com/nrabulinski/settei";
          instances = 6;
        };
      };
      common.incus.enable = true;

      services.nginx = {
        enable = true;
        appendHttpConfig = ''
          include /impure/nginx/*.conf;
        '';
      };
      networking.firewall.allowedTCPPorts = [ 80 ];
    };
}
