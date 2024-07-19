{ username, lib, ... }:
{
  services.jellyfin.enable = true;
  services.radarr.enable = true;
  services.sonarr.enable = true;
  services.prowlarr.enable = true;
  services.deluge = {
    enable = true;
    web.enable = true;
    config.download_location = "/media/deluge";
  };

  services.restic.server = {
    enable = true;
    dataDir = "/media/restic";
  };

  users.users = {
    jellyfin.extraGroups = [
      "radarr"
      "sonarr"
    ];
    radarr.extraGroups = [ "deluge" ];
    sonarr.extraGroups = [ "deluge" ];
    ${username}.extraGroups = [ "deluge" ];
  };

  systemd.services =
    lib.genAttrs
      [
        "jellyfin"
        "radarr"
        "sonarr"
        "prowlarr"
        "deluged"
        "restic-rest-server"
      ]
      (_: {
        requires = [ "zfs-mount.service" ];
        after = [ "zfs-mount.service" ];
      });
}
