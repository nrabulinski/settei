{
  configurations.nixos.legion = {
    config,
    lib,
    username,
    ...
  }: {
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
      kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
      loader.systemd-boot.enable = true;
      loader.efi.canTouchEfiVariables = true;
    };

    networking = {
      hostName = "legion";
      hostId = builtins.substring 0 8 (builtins.readFile ./machine-id);
      networkmanager.enable = true;
      firewall.trustedInterfaces = ["tailscale0"];
    };
    systemd.services.NetworkManager-wait-online.enable = false;

    powerManagement.cpuFreqGovernor = "performance";

    age.secrets.niko-pass.file = ../../secrets/legion-niko-pass.age;
    users.users.${username}.hashedPasswordFile = config.age.secrets.niko-pass.path;

    common.hercules.enable = true;
    common.github-runner = {
      enable = true;
      runners.settei = {
        url = "https://github.com/nrabulinski/settei";
        instances = 4;
      };
    };
  };
}
