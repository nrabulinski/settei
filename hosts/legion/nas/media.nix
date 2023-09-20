{username, ...}: {
  services.jellyfin.enable = true;
  services.radarr.enable = true;
  services.sonarr.enable = true;
  services.prowlarr.enable = true;
  services.deluge = {
    enable = true;
    web.enable = true;
    config.download_location = "/media/deluge";
  };

  users.users = {
    jellyfin.extraGroups = ["radarr" "sonarr"];
    radarr.extraGroups = ["deluge"];
    sonarr.extraGroups = ["deluge"];
    ${username}.extraGroups = ["deluge"];
  };
}
