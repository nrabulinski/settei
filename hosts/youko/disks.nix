{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/nvme0n1";
    content = {
      type = "gpt";
      partitions = {
        esp = {
          size = "512M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        luks = {
          size = "100%";
          content = {
            type = "luks";
            name = "crypted";
            settings.allowDiscards = true;
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes =
                let
                  mountOptions = [
                    "noatime"
                    "compress=zstd"
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
                  "/swap" = {
                    mountpoint = "/.swapvol";
                    swap.swapfile.size = "16G";
                  };
                };
            };
          };
        };
      };
    };
  };
}
