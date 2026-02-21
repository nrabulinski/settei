{
  config,
  lib,
  pkgs,
  inputs',
  ...
}:
let
  formatJson = pkgs.formats.json { };
  serverDomain = "matrix.nrab.lol";
in
{
  services.matrix-conduit = {
    enable = true;
    package = inputs'.settei.packages.conduit-next;
    settings.global = {
      address = "127.0.0.1";
      server_name = "nrab.lol";
      database_backend = "rocksdb";
      allow_registration = false;
      allow_check_for_updates = false;
      max_request_size = 100 * 1024 * 1024;
      conduit_cache_capacity_modifier = 4.0;
    };
  };
  systemd.services.conduit.serviceConfig.LimitNOFILE = 8192;

  networking.firewall.allowedTCPPorts = [
    80
    443
    8448
  ];

  services.nginx = {
    enable = true;
    virtualHosts = {
      "nrab.lol" = {
        forceSSL = true;
        enableACME = true;

        locations."=/.well-known/matrix/server" = {
          alias = formatJson.generate "well-known-matrix-server" { "m.server" = serverDomain; };
          extraConfig = ''
            default_type application/json;
            add_header Access-Control-Allow-Origin "*";
          '';
        };

        locations."=/.well-known/matrix/client" = {
          alias = formatJson.generate "well-known-matrix-client" {
            "m.homeserver" = {
              "base_url" = "https://${serverDomain}";
            };
            "org.matrix.msc3575.proxy" = {
              "url" = "https://${serverDomain}";
            };
          };
          extraConfig = ''
            default_type application/json;
            add_header Access-Control-Allow-Origin "*";
          '';
        };
      };

      "matrix.nrab.lol" = {
        forceSSL = true;
        enableACME = true;
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
        extraConfig = ''
          merge_slashes off;
        '';

        locations."/_matrix/" = {
          proxyPass = "http://backend_conduit$request_uri";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_buffering off;
          '';
        };
      };
    };

    upstreams."backend_conduit".servers = {
      "localhost:${toString config.services.matrix-conduit.settings.global.port}" = { };
    };
  };
}
