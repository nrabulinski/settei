{
  pkgs,
  username,
  ...
}: {
  imports = [
    ./media.nix
  ];

  boot.supportedFilesystems = ["zfs"];

  boot.zfs.extraPools = ["yottapool"];
  services.zfs = {
    autoScrub.enable = true;
    zed.settings = {
      ZED_DEBUG_LOG = "/tmp/zed.debug.log";
      ZED_EMAIL_ADDR = [username];
      ZED_EMAIL_PROG = "${pkgs.msmtp}/bin/msmtp";
      ZED_EMAIL_OPTS = "@ADDRESS@";

      ZED_NOTIFY_INTERVAL_SECS = 3600;
      ZED_NOTIFY_VERBOSE = true;

      ZED_USE_ENCLOSURE_LEDS = true;
      ZED_SCRUB_AFTER_RESILVER = true;
    };
  };

  fileSystems."/nix-cache" = {
    device = "/dev/disk/by-label/CACHE";
    fsType = "ext4";
  };
}
