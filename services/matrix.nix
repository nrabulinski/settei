let
  # generate a list of numbers from start to end inclusive
  range = start: end: builtins.genList (x: x + start) (end - start + 1);
in
{
  config.services.matrix = {
    host = "kazuki";
    ports = [
      # continuwuity
      6168
      # turn/stun
      3478
      5349
      # livekit
      7881
    ]
    # media relay
    ++ (range 50201 65535)
    # livekit
    ++ (range 50100 50200);
    module =
      { config, lib, ... }:
      {
        age.secrets.rab-lol-cf = {
          file = ../secrets/rab-lol-cf.age;
          owner = config.services.nginx.user;
        };
        age.secrets.coturn-secret = {
          file = ../secrets/coturn-secret.age;
          owner = "turnserver";
          group = "continuwuity";
          mode = "440";
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
            turn_uris = [
              "turn:turn.rab.lol?transport=udp"
              "turn:turn.rab.lol?transport=tcp"
              "turns:turn.rab.lol?transport=udp"
              "turns:turn.rab.lol?transport=tcp"
            ];
            turn_secret_file = config.age.secrets.coturn-secret.path;
            turn_ttl = 86400;
          };
        };

        services.coturn = {
          enable = true;
          realm = "rab.lol";
          use-auth-secret = true;
          min-port = 50201;
          max-port = 65535;
          no-cli = true;
          cert = "${config.security.acme.certs."turn.rab.lol".directory}/fullchain.pem";
          pkey = "${config.security.acme.certs."turn.rab.lol".directory}/key.pem";
          static-auth-secret-file = config.age.secrets.coturn-secret.path;
        };

        networking.firewall.allowedTCPPorts = [
          80
          443
          8448
          # turn/stun
          3478
          5349
          # livekit
          7881
        ];
        networking.firewall.allowedUDPPorts = [
          # turn/stun
          3478
          5349
        ]
        # media relay
        ++ (range 50201 65535)
        # livekit
        ++ (range 50100 50200);

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
        security.acme.certs."turn.rab.lol" = {
          email = "nikodem@rabulinski.com";
          dnsProvider = "cloudflare";
          credentialsFile = config.age.secrets.rab-lol-cf.path;
          group = "turnserver";
        };
      };
  };
}
