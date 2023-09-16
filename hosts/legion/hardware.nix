{...}: {
  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "uas"];
  boot.extraModulePackages = with config.boot.kernelPackages; [acpi_call];
  boot.kernelModules = ["kvm-intel" "i2c-dev" "acpi_call"];
  boot.blacklistedKernelModules = ["nouveau"];

  hardware = {
    enableAllFirmware = true;
    cpu.intel.updateMicrocode = true;
  };

  services.smartd.enable = true;

  # TODO: Move to disko only
  # TODO: Actually set up impermanence
  boot.supportedFilesystems = ["btrfs"];
  boot.initrd.luks.devices."enc".device = "/dev/disk/by-label/LUKS";

  fileSystems."/" = {
    device = "/dev/disk/by-label/LINUX";
    fsType = "btrfs";
    options = ["subvol=root" "compress=zstd" "noatime"];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-label/LINUX";
    fsType = "btrfs";
    options = ["subvol=home" "compress=zstd" "noatime"];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-label/LINUX";
    fsType = "btrfs";
    options = ["subvol=nix" "compress=zstd" "noatime"];
  };

  fileSystems."/persist" = {
    device = "/dev/disk/by-label/LINUX";
    fsType = "btrfs";
    options = ["subvol=persist" "compress=zstd" "noatime"];
  };

  fileSystems."/var/log" = {
    device = "/dev/disk/by-label/LINUX";
    fsType = "btrfs";
    options = ["subvol=log" "compress=zstd" "noatime"];
    neededForBoot = true;
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
  };

  swapDevices = [
    {device = "/dev/disk/by-label/SWAP";}
  ];
}
