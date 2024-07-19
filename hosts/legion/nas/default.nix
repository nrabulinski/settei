{
  pkgs,
  lib,
  username,
  ...
}:
{
  imports = [ ./media.nix ];

  boot.supportedFilesystems = [
    "ext4"
    "zfs"
  ];

  boot.zfs.extraPools = [ "yottapool" ];
  services.zfs = {
    autoScrub.enable = true;
    zed.settings = {
      ZED_DEBUG_LOG = "/tmp/zed.debug.log";
      ZED_EMAIL_ADDR = [ username ];
      ZED_EMAIL_PROG = lib.getExe pkgs.msmtp;
      ZED_EMAIL_OPTS = "@ADDRESS@";

      ZED_NOTIFY_INTERVAL_SECS = 3600;
      ZED_NOTIFY_VERBOSE = true;

      ZED_USE_ENCLOSURE_LEDS = true;
      ZED_SCRUB_AFTER_RESILVER = true;
    };
  };

  fileSystems."/bulk" = {
    device = "/dev/disk/by-label/BULK";
    fsType = "ext4";
  };

  systemd.mounts = [
    {
      type = "none";
      options = "bind";
      what = "/media/data";
      where = "/export/yotta-data";
      requires = [ "zfs-mount.service" ];
      after = [ "zfs-mount.service" ];
      wantedBy = [ "multi-user.target" ];
      before = ["nfs-server.service"];
      requiredBy = ["nfs-server.service"];
    }
  ];

  services.nfs.server = {
    enable = true;
    hostName = "100.84.112.35";
    exports = ''
      /export            *(insecure,rw,crossmnt,fsid=0)
      /export/yotta-data *(insecure,rw,nohide)
    '';
  };
}
