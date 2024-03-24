{ config, ... }:
{
  settei.containers.zitadel.config = {
    services.zitadel = {
      enable = true;
      settings = {
        Port = 80;
        Database.postgres = {
          Host = "localhost";
          Port = 5432;
          Database = "zitadel";
          User = {
            Username = "zitadel";
            SSL.Mode = "disable";
          };
        };
        ExternalDomain = "zitadel.rabulinski.com";
        ExternalPort = 443;
        ExternalSecure = true;
      };
      openFirewall = true;
    };

    services.postgresql = {
      enable = true;
      enableJIT = true;
      ensureDatabases = [ "zitadel" ];
      ensureUsers = [
        {
          name = "zitadel";
          ensureDBOwnership = true;
          ensureClauses.login = true;
        }
      ];
    };
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
    virtualHosts."zitadel.rabulinski.com" = {
      forceSSL = true;
      enableACME = true;
      acmeRoot = null;
      locations."/" = {
        extraConfig = ''
          grpc_pass grpc://${config.settei.containers.zitadel.localAddress}:80;
          grpc_set_header Host $host:$server_port;
        '';
      };
    };
  };
}
