{
  services.attic =
    let
      atticPort = 9476;
    in
    {
      host = "kazuki";
      ports = [ atticPort ];
      config =
        { config, ... }:
        {
          age.secrets.attic-creds = {
            file = ../secrets/attic-creds.age;
            owner = config.services.atticd.user;
          };
          age.secrets.nrab-lol-cf = {
            file = ../secrets/nrab-lol-cf.age;
            owner = config.services.nginx.user;
          };

          services.atticd = {
            enable = true;
            environmentFile = config.age.secrets.attic-creds.path;
            settings = {
              listen = "[::]:${toString atticPort}";
              storage = {
                type = "local";
                path = "/storage-box";
              };
              compression.type = "none";
              chunking = {
                nar-size-threshold = 0;
                min-size = 0;
                avg-size = 0;
                max-size = 0;
              };
              api-endpoint = "https://attic.nrab.lol/";
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

          systemd.services.atticd = {
            after = [ "storage\\x2dbox.mount" ];
          };

          security.acme = {
            acceptTerms = true;
            defaults.email = "nikodem@rabulinski.com";
          };

          users.users.nginx.extraGroups = [ "acme" ];
          networking.firewall.allowedTCPPorts = [
            80
            443
          ];

          services.nginx = {
            enable = true;
            recommendedProxySettings = true;
            recommendedGzipSettings = true;
            recommendedOptimisation = true;
            recommendedTlsSettings = true;
            virtualHosts."attic.nrab.lol" = {
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
            virtualHosts."cache.nrab.lol" = {
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
                proxy_cache_valid 200 24h;
              '';
            };

            upstreams."attic".servers = {
              "localhost:${toString atticPort}" = { };
            };

            appendHttpConfig = ''
              proxy_cache_path /var/cache/nginx/nixstore levels=1:2 keys_zone=nixstore:10m max_size=10g inactive=24h use_temp_path=off;
            '';
          };

          security.acme.certs."attic.nrab.lol" = {
            dnsProvider = "cloudflare";
            credentialsFile = config.age.secrets.nrab-lol-cf.path;
          };

          security.acme.certs."cache.nrab.lol" = {
            dnsProvider = "cloudflare";
            credentialsFile = config.age.secrets.nrab-lol-cf.path;
          };
        };
    };
}
