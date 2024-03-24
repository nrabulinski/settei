{ config, ... }:
{
  age.secrets.rabulinski-com-cf = {
    file = ../../secrets/rabulinski-com-cf.age;
    owner = config.services.nginx.user;
  };
  age.secrets.zitadel-master = {
    file = ../../secrets/zitadel-master.age;
  };

  settei.containers.zitadel.config = {
    services.zitadel = {
      enable = true;
      masterKeyFile = "/zitadel-master-key";
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
  settei.containers.zitadel.bindMounts = {
    "/zitadel-master-key".hostPath = config.age.secrets.zitadel-master.path;
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

  security.acme.certs."zitadel.rabulinski.com" = {
    dnsProvider = "cloudflare";
    credentialsFile = config.age.secrets.rabulinski-com-cf.path;
  };
}
