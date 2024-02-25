args:
let
  bootDevice = args.bootDevice or "/dev/sda";
in
{
  disko.devices.disk.bootDisk = {
    type = "disk";
    device = bootDevice;
    content = {
      type = "table";
      format = "gpt";
      partitions = [
        {
          name = "EFI";
          start = "1MiB";
          end = "128MiB";
          fs-type = "fat32";
          bootable = true;
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        }
        {
          name = "LINUX";
          start = "128MiB";
          end = "-4G";
          content = {
            type = "btrfs";
            extraArgs = [ "-f" ];
            subvolumes =
              let
                mountOptions = [
                  "compress=zstd"
                  "noatime"
                ];
              in
              {
                "/root" = {
                  inherit mountOptions;
                  mountpoint = "/";
                };
                "/nix" = {
                  inherit mountOptions;
                  mountpoint = "/nix";
                };
              };
          };
        }
        {
          name = "SWAP";
          start = "-4G";
          end = "100%";
          content = {
            type = "swap";
            randomEncryption = true;
          };
        }
      ];
    };
  };
}
