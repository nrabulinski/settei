{
  config.services.attic-youko =
    let
      atticPort = 9478;
    in
    {
      host = "youko";
      ports = [ atticPort ];
      module =
        { config, ... }:
        {
          age.secrets.attic-creds = {
            file = ../secrets/attic-creds.age;
            owner = config.services.atticd.user;
          };
          age.secrets.rab-lol-cf = {
            file = ../secrets/rab-lol-cf.age;
            owner = config.services.nginx.user;
          };

          services.atticd = {
            enable = true;
            environmentFile = config.age.secrets.attic-creds.path;
            settings = {
              listen = "[::]:${toString atticPort}";
              storage = {
                type = "local";
                path = "/media/attic";
              };
              compression.type = "none";
              chunking = {
                nar-size-threshold = 64 * 1024;
                min-size = 16 * 1024;
                avg-size = 64 * 1024;
                max-size = 256 * 1024;
              };
              api-endpoint = "https://attic.rab.lol/";
            };
          };

          users = {
            users.atticd = {
              uid = 990;
              isSystemUser = true;
              group = "atticd";
              home = "/var/lib/atticd";
              createHome = true;
            };
            groups.atticd = {
              gid = 988;
            };
          };

          networking.firewall.allowedTCPPorts = [
            80
            443
          ];

          services.nginx.enable = true;
          services.nginx.upstreams.attic.servers."localhost:${toString atticPort}" = { };
          services.nginx.virtualHosts."attic.rab.lol" = {
            forceSSL = true;
            enableACME = true;
            acmeRoot = null;
            locations."/" = {
              proxyPass = "http://attic";
            };
            extraConfig = ''
              client_max_body_size 24G;
            '';
          };
          services.nginx.virtualHosts."cache.rab.lol" = {
            forceSSL = true;
            enableACME = true;
            acmeRoot = null;
            locations."/" = {
              proxyPass = "http://attic/public$request_uri";
            };
            extraConfig = ''
              proxy_cache nixstore;
              proxy_cache_use_stale error timeout http_500 http_502;
              proxy_cache_lock on;
              proxy_cache_key $request_uri;
              proxy_cache_valid 200 2d;
            '';
          };
          services.nginx.proxyCachePath.nixstore = {
            enable = true;
            keysZoneName = "nixstore";
            inactive = "2d";
          };

          users.users.nginx.extraGroups = [ "acme" ];
          security.acme.acceptTerms = true;
          security.acme.certs."attic.rab.lol" = {
            email = "nikodem@rabulinski.com";
            dnsProvider = "cloudflare";
            credentialsFile = config.age.secrets.rab-lol-cf.path;
          };
          security.acme.certs."cache.rab.lol" = {
            email = "nikodem@rabulinski.com";
            dnsProvider = "cloudflare";
            credentialsFile = config.age.secrets.rab-lol-cf.path;
          };
        };
    };
}
