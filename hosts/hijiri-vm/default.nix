{
  configurations.nixos.hijiri-vm =
    {
      modulesPath,
      lib,
      username,
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

      networking.domain = "hijiri";
      networking.hostName = "vm";

      services.prometheus.exporters.node.enable = lib.mkForce false;
    };
}
