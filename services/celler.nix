{
  config.services.celler-youko =
    let
      cellerPort = 9478;
    in
    {
      host = "youko";
      ports = [ cellerPort ];
      module =
        { config, lib, ... }:
        {
          age.secrets.celler-creds = {
            file = ../secrets/attic-creds.age;
            owner = config.services.cellerd.user;
          };
          age.secrets.rab-lol-cf = {
            file = ../secrets/rab-lol-cf.age;
            owner = config.services.nginx.user;
          };

          services.cellerd = {
            enable = true;
            environmentFile = config.age.secrets.celler-creds.path;
            settings = {
              listen = "[::]:${toString cellerPort}";
              database.url = "sqlite:///var/lib/atticd/server.db?mode=rwc";
              storage = {
                type = "local";
                path = "/media/attic";
              };
              compression.type = "none";
              chunking = {
                nar-size-threshold = 0;
                min-size = 16 * 1024;
                avg-size = 64 * 1024;
                max-size = 256 * 1024;
              };
              api-endpoint = "https://celler.rab.lol/";
            };
          };

          systemd.services.cellerd.serviceConfig.StateDirectory = lib.mkForce "atticd";

          users = {
            users.cellerd = {
              isSystemUser = true;
              group = "cellerd";
              home = "/var/lib/atticd";
              createHome = true;
            };
            groups.cellerd = { };
          };

          networking.firewall.allowedTCPPorts = [
            80
            443
          ];

          services.nginx.enable = true;
          services.nginx.upstreams.celler.servers."localhost:${toString cellerPort}" = { };
          services.nginx.virtualHosts."celler.rab.lol" = {
            forceSSL = true;
            enableACME = true;
            acmeRoot = null;
            locations."/" = {
              proxyPass = "http://celler";
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
              proxyPass = "http://celler/public$request_uri";
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

          security.acme.certs."celler.rab.lol" = {
            email = "nikodem@rabulinski.com";
            dnsProvider = "cloudflare";
            credentialFiles.CF_DNS_API_TOKEN_FILE = config.age.secrets.rab-lol-cf.path;
          };
          security.acme.certs."cache.rab.lol" = {
            email = "nikodem@rabulinski.com";
            dnsProvider = "cloudflare";
            credentialFiles.CF_DNS_API_TOKEN_FILE = config.age.secrets.rab-lol-cf.path;
          };
        };
    };
}
