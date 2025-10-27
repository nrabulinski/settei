{
  config.services.ddns = {
    host = "kazuki";
    ports = [ 50002 ];
    module =
      {
        config,
        lib,
        inputs',
        ...
      }:
      {
        age.secrets.rab-lol-cf = {
          file = ../secrets/rab-lol-cf.age;
          owner = config.services.nginx.user;
        };
        age.secrets.ddns-secret = {
          file = ../secrets/ddns-secret.age;
        };

        systemd.services.settei-ddns-server = {
          script = lib.getExe' inputs'.settei.packages.ddns "server";
          wantedBy = [ "multi-user.target" ];
          wants = [ "network-online.target" ];
          after = [ "network-online.target" ];
          environment = {
            DOMAIN = "rab.lol";
            PORT = "50002";
            CF_KEY_PATH = config.age.secrets.rab-lol-cf.path;
            SECRET_PATH = config.age.secrets.ddns-secret.path;
          };
          serviceConfig.Restart = "on-failure";
        };

        services.nginx = {
          enable = true;
          recommendedProxySettings = true;
          recommendedGzipSettings = true;
          recommendedOptimisation = true;
          recommendedTlsSettings = true;
          virtualHosts."ddns.rab.lol" = {
            forceSSL = true;
            enableACME = true;
            acmeRoot = null;
            locations."/".proxyPass = "http://127.0.0.1:50002";
          };
        };

        security.acme.acceptTerms = true;
        security.acme.certs."ddns.rab.lol" = {
          email = "nikodem@rabulinski.com";
          dnsProvider = "cloudflare";
          credentialsFile = config.age.secrets.rab-lol-cf.path;
        };
      };
  };
}
