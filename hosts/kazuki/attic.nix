{
  config,
  lib,
  ...
}: let
  atticPort = 9476;
in {
  age.secrets.attic-creds = {
    file = ../../secrets/attic-creds.age;
    owner = config.services.atticd.user;
  };
  age.secrets.nrab-lol-cf = {
    file = ../../secrets/nrab-lol-cf.age;
    owner = config.services.nginx.user;
  };

  services.atticd = {
    enable = true;
    credentialsFile = config.age.secrets.attic-creds.path;
    settings = {
      listen = "[::]:${toString atticPort}";
      storage = {
        type = "local";
        path = "/storage-box/attic";
      };
      compression.type = "zstd";
      chunking = {
        nar-size-threshold = 64 * 1024;
        min-size = 16 * 1024;
        avg-size = 64 * 1024;
        max-size = 256 * 1024;
      };
      api-endpoint = "https://cache.nrab.lol/";
      allowed-hosts = ["cache.nrab.lol"];
    };
  };

  users = {
    users.atticd = {
      isSystemUser = true;
      group = "atticd";
      home = "/var/lib/atticd";
      createHome = true;
    };
    groups.atticd = {};
  };

  systemd.services.atticd = {
    after = ["storage\\x2dbox.mount"];
    serviceConfig.DynamicUser = lib.mkForce false;
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "nikodem@rabulinski.com";
  };

  users.users.nginx.extraGroups = ["acme"];
  networking.firewall.allowedTCPPorts = [80 443];

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts."cache.nrab.lol" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://attic";
      };
      extraConfig = ''
        client_max_body_size 8G;
      '';
    };

    upstreams."attic".servers = {
      "localhost:${toString atticPort}" = {};
    };
  };

  security.acme.certs."cache.nrab.lol" = {
    dnsProvider = "cloudflare";
    credentialsFile = config.age.secrets.nrab-lol-cf.path;
    webroot = null;
  };
}
