{ config, ... }:
{
  age.secrets.storage-box-webdav = {
    file = ../../secrets/storage-box-webdav.age;
  };

  services.davfs2 = {
    enable = true;
    extraConfig = ''
      cache_size 50000
      minimize_mem 1
      use_locks 0
    '';
  };
  environment.etc."davfs2/secrets".source = config.age.secrets.storage-box-webdav.path;

  fileSystems."/storage-box" = {
    fsType = "davfs";
    device = "https://u389358.your-storagebox.de";
    options = [
      "x-systemd.automount"
      "x-systemd.device-timeout=5s"
      "x-systemd.mount-timeout=5s"
      "noauto"
      "uid=${toString config.users.users.atticd.uid}"
      "gid=${toString config.users.groups.atticd.gid}"
      "rw"
    ];
  };
}
