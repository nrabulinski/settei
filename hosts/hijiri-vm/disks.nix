args:
let
  bootDevice = args.bootDevice or "/dev/vda";
in
{
  disko.devices.disk.bootDisk = {
    type = "disk";
    device = bootDevice;
    content = {
      type = "gpt";
      partitions = {
        esp = {
          label = "EFI";
          priority = 1;
          start = "1MiB";
          end = "128MiB";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        };
        linux = {
          label = "LINUX";
          size = "100%";
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
        };
      };
    };
  };
}
