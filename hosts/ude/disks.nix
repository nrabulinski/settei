args: let
  bootDevice = args.bootDevice or "/dev/sda";
in {
  disko.devices = {
    disk = {
      vdb = {
        type = "disk";
        device = bootDevice;
        content = {
          type = "gpt";
          partitions = {
            esp = {
              priority = 1;
              start = "1M";
              end = "128M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            linux = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = ["-f"];
                subvolumes = let
                  mountOptions = ["compress=zstd" "noatime"];
                in {
                  "/root" = {
                    mountpoint = "/";
                    inherit mountOptions;
                  };
                  "/nix" = {
                    mountpoint = "/nix";
                    inherit mountOptions;
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
