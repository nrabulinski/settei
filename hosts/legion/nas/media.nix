{
  config,
  username,
  lib,
  ...
}:
{
  age.secrets.rab-lol-cf = {
    file = ../../../secrets/rab-lol-cf.age;
    owner = config.services.nginx.user;
  };

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };
  services.radarr.enable = true;
  # TODO: Remove once https://github.com/Sonarr/Sonarr/pull/7443 is merged
  nixpkgs.config.permittedInsecurePackages = [
    "dotnet-sdk-6.0.428"
    "aspnetcore-runtime-6.0.36"
  ];
  services.sonarr.enable = true;
  services.prowlarr.enable = true;
  services.jellyseerr.enable = true;
  services.deluge = {
    enable = true;
    web.enable = true;
    config.download_location = "/media/deluge";
  };

  services.restic.server = {
    enable = true;
    dataDir = "/media/restic";
    extraFlags = [ "--no-auth" ];
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

  systemd.services = lib.mkMerge [
    (lib.genAttrs
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
      })
    )
    {
      jellyseerr.requires = [
        "jellyfin.service"
        "radarr.service"
        "sonarr.service"
      ];

      radarr.requires = [ "deluged.service" ];
      sonarr.requires = [ "deluged.service" ];
    }
  ];

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts =
      let
        services = [
          "jellyfin"
          "jellyseerr"
          "deluge"
          "prowlarr"
          "sonarr"
          "radarr"
        ];
        mkService = name: {
          forceSSL = true;
          useACMEHost = "_wildcard.legion.rab.lol";
          listen = lib.flatten (
            map
              (port: [
                (port // { addr = config.settei.tailscale.ipv4; })
                (port // { addr = "[${config.settei.tailscale.ipv6}]"; })
              ])
              [
                { port = 80; }
                {
                  port = 443;
                  ssl = true;
                }
              ]
          );

          locations."/".proxyPass = "http://${name}";
        };
        services' = map (service: {
          name = "${service}.legion.rab.lol";
          value = mkService service;
        }) services;
      in
      lib.listToAttrs services';
    upstreams = {
      jellyfin.servers."localhost:8096" = { };
      jellyseerr.servers."localhost:5055" = { };
      deluge.servers."localhost:8112" = { };
      prowlarr.servers."localhost:9696" = { };
      radarr.servers."localhost:7878" = { };
      sonarr.servers."localhost:8989" = { };
    };
  };

  users.users.nginx.extraGroups = [ "acme" ];
  security.acme.acceptTerms = true;
  security.acme.certs."_wildcard.legion.rab.lol" = {
    domain = "*.legion.rab.lol";
    dnsProvider = "cloudflare";
    credentialsFile = config.age.secrets.rab-lol-cf.path;
    email = "nikodem@rabulinski.com";
  };
}
