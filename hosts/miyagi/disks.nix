args:
let
  bootDevice = args.bootDevice or "/dev/nvme0n1";
in
{
  disko.devices.disk.bootDisk = {
    type = "disk";
    device = bootDevice;
    content = {
      type = "gpt";
      partitions = {
        esp = {
          label = "ESP";
          priority = 3;
          type = "EF00";
          start = "1MiB";
          end = "512MiB";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        };
        nixos = {
          label = "primary";
          priority = 1;
          start = "512MiB";
          end = "-8G";
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
                "/home" = {
                  inherit mountOptions;
                  mountpoint = "/home";
                };
                "/nix" = {
                  inherit mountOptions;
                  mountpoint = "/nix";
                };
                "/persist" = {
                  inherit mountOptions;
                  mountpoint = "/persist";
                };
                "/log" = {
                  inherit mountOptions;
                  mountpoint = "/var/log";
                };
              };
          };
        };
        swap = {
          label = "swap";
          priority = 2;
          size = "100%";
          content.type = "swap";
        };
      };
    };
  };

  fileSystems."/var/log".neededForBoot = true;

  fileSystems."/bulk" = {
    device = "/dev/disk/by-label/bulk";
    fsType = "btrfs";
    options = [
      "compress=zstd"
      "noatime"
    ];
  };
}
