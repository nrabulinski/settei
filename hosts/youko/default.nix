{
  configurations.nixos.youko =
    {
      config,
      lib,
      username,
      ...
    }:
    {
      imports = [
        ./disks.nix
        ./hardware.nix
        ./sway.nix
        ./msmtp.nix
        ./nas.nix
      ];

      nixpkgs.hostPlatform = "x86_64-linux";

      boot = {
        loader.systemd-boot.enable = true;
        loader.efi.canTouchEfiVariables = true;
      };

      networking.networkmanager.enable = true;

      age.secrets.niko-pass.file = ../../secrets/youko-niko-pass.age;
      users.users.${username}.hashedPasswordFile = config.age.secrets.niko-pass.path;

      settei.user.config = {
        settei.desktop.enable = true;
      };

      services.udisks2.enable = true;
      settei.incus.enable = true;
      virtualisation.podman.enable = true;
      hardware.keyboard.qmk.enable = true;

      settei.unfree.allowedPackages = [ "vmware-workstation" ];
      virtualisation.vmware.host.enable = true;
      environment.etc."vmware/config" = lib.mkForce {
        source = "${config.virtualisation.vmware.host.package}/etc/vmware/config";
        text = null;
      };

      networking.hostId = "b49ee8de";
    };
}
