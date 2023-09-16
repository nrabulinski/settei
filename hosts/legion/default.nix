{config, ...}: let
  inherit (config.assets) sshKeys;
in {
  configurations.nixos.legion = {
    config,
    lib,
    ...
  }: {
    imports = [
      ./hardware.nix
      # ./disks.nix
    ];

    nixpkgs.system = "x86_64-linux";

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
      useDHCP = true;
      firewall.trustedInterfaces = ["tailscale0"];
    };

    powerManagement.cpuFreqGovernor = "performance";
  };
}
