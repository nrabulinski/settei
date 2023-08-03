{
  config,
  pkgs,
  inputs',
  ...
}: let
  formatJson = pkgs.formats.json {};
in {
  services.matrix-conduit = {
    enable = true;
    package = inputs'.niko-nur.packages.conduit-latest;
    settings.global = {
      server_name = "nrab.lol";
      database_backend = "rocksdb";
      allow_registration = false;
    };
  };
  systemd.services.conduit.serviceConfig.LimitNOFILE = 8192;

  security.acme = {
    acceptTerms = true;
    defaults.email = "nikodem@rabulinski.com";
  };

  users.users.nginx.extraGroups = ["acme"];
  networking.firewall.allowedTCPPorts = [80 443 8448 2222];

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts = {
      "nrab.lol" = {
        forceSSL = true;
        enableACME = true;

        locations."=/.well-known/matrix/server" = {
          alias = formatJson.generate "well-known-matrix-server" {
            "m.server" = "matrix.nrab.lol";
          };
          extraConfig = ''
            default_type application/json;
            add_header Access-Control-Allow-Origin "*";
          '';
        };

        locations."=/.well-known/matrix/client" = {
          alias = formatJson.generate "well-known-matrix-client" {
            "m.homeserver" = {
              "base_url" = "https://matrix.nrab.lol";
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
        listen = [
          {
            addr = "0.0.0.0";
            port = 80;
          }
          {
            addr = "0.0.0.0";
            port = 443;
            ssl = true;
          }
          {
            addr = "0.0.0.0";
            port = 8448;
            ssl = true;
          }
        ];
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
      "localhost:${toString config.services.matrix-conduit.settings.global.port}" = {};
    };
  };
}
