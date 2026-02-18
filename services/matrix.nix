{
  config.services.matrix = {
    host = "kazuki";
    ports = [ 6168 ];
    module =
      { config, lib, ... }:
      {
        age.secrets.rab-lol-cf = {
          file = ../secrets/rab-lol-cf.age;
          owner = config.services.nginx.user;
        };

        services.matrix-continuwuity = {
          enable = true;
          settings.global = {
            address = [ "127.0.0.1" ];
            port = [ 6168 ];
            server_name = "rab.lol";
            allow_registration = false;
            max_request_size = 1024 * 1024 * 1024;
            well_known = {
              client = "https://matrix.rab.lol";
              server = "matrix.rab.lol:443";
            };
          };
        };

        services.nginx.enable = true;
        services.nginx.virtualHosts."rab.lol" = {
          forceSSL = true;
          enableACME = true;
          acmeRoot = null;
          locations."/.well-known/matrix" = {
            proxyPass = "http://continuwuity$request_uri";
          };
        };
        services.nginx.virtualHosts."matrix.rab.lol" = {
          listen =
            let
              ports = [
                { port = 80; }
                {
                  port = 443;
                  ssl = true;
                }
                {
                  port = 8448;
                  ssl = true;
                }
              ];
            in
            lib.flatten (
              map (port: [
                (port // { addr = "0.0.0.0"; })
                (port // { addr = "[::0]"; })
              ]) ports
            );
          forceSSL = true;
          enableACME = true;
          acmeRoot = null;
          locations."/" = {
            proxyPass = "http://continuwuity";
            proxyWebsockets = true;
          };
          extraConfig = ''
            proxy_buffering off;
            client_max_body_size 1G;
          '';
        };
        services.nginx.upstreams.continuwuity.servers = {
          "localhost:${toString config.services.matrix-continuwuity.settings.global.port}" = { };
        };

        security.acme.acceptTerms = true;
        security.acme.certs."rab.lol" = {
          email = "nikodem@rabulinski.com";
          dnsProvider = "cloudflare";
          credentialsFile = config.age.secrets.rab-lol-cf.path;
        };
        security.acme.certs."matrix.rab.lol" = {
          email = "nikodem@rabulinski.com";
          dnsProvider = "cloudflare";
          credentialsFile = config.age.secrets.rab-lol-cf.path;
        };
      };
  };
}
