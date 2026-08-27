{
  boot.initrd.luks.devices."enc".device = "/dev/disk/by-uuid/e1e248fb-308e-4a87-8fd4-0417dfa03842";

  fileSystems."/" = {
    device = "/dev/mapper/enc";
    fsType = "btrfs";
    options = [ "subvol=root" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/BFCD-1AF9";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  fileSystems."/home" = {
    device = "/dev/mapper/enc";
    fsType = "btrfs";
    options = [ "subvol=home" ];
  };

  fileSystems."/nix" = {
    device = "/dev/mapper/enc";
    fsType = "btrfs";
    options = [ "subvol=nix" ];
  };

  fileSystems."/.swapvol" = {
    device = "/dev/mapper/enc";
    fsType = "btrfs";
    options = [ "subvol=swap" ];
  };

  swapDevices = [
    {
      device = "/.swapvol/swapfile";
    }
  ];
}
