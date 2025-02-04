{
  configurations.nixos.legion =
    {
      config,
      username,
      ...
    }:
    {
      imports = [
        ./hardware.nix
        # ./disks.nix
        ./msmtp.nix
        ./desktop.nix
      ];

      nixpkgs.hostPlatform = "x86_64-linux";

      specialisation = {
        nas.configuration = ./nas;
      };

      boot = {
        loader.systemd-boot.enable = true;
        loader.efi.canTouchEfiVariables = true;
      };

      settei.tailscale = {
        ipv4 = "100.84.112.35";
        ipv6 = "fd7a:115c:a1e0:ab12:4843:cd96:6254:7023";
      };

      networking = {
        hostName = "legion";
        hostId = builtins.substring 0 8 "524209a432724c7abaf04398cdd6eecd";
        networkmanager.enable = true;
      };
      systemd.services.NetworkManager-wait-online.enable = false;

      powerManagement.cpuFreqGovernor = "performance";

      age.secrets.niko-pass.file = ../../secrets/legion-niko-pass.age;
      users.users.${username}.hashedPasswordFile = config.age.secrets.niko-pass.path;

      settei.incus.enable = true;
      virtualisation.podman.enable = true;
    };
}
