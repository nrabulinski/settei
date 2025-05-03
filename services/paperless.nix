{
  config.services.paperless = {
    host = "youko";
    ports = [ 28981 ];
    module =
      { config, ... }:
      {
        age.secrets.rab-lol-cf = {
          file = ../secrets/rab-lol-cf.age;
          owner = config.services.nginx.user;
        };
        age.secrets.paperless-pass = {
          file = ../secrets/paperless-pass.age;
          owner = config.services.paperless.user;
        };

        services.paperless = {
          enable = true;
          dataDir = "/var/lib/paperless";
          mediaDir = "/media/paperless/media";
          consumptionDir = "/media/paperless/consume";
          passwordFile = config.age.secrets.paperless-pass.path;
          settings = {
            PAPERLESS_CONSUMER_IGNORE_PATTERN = [
              ".DS_STORE/*"
              "desktop.ini"
            ];
            PAPERLESS_OCR_LANGUAGE = "pol+eng+jpn";
            PAPERLESS_OCR_USER_ARGS = {
              optimize = 1;
              pdfa_image_compression = "lossless";
            };
          };
        };

        services.nginx = {
          enable = true;
          recommendedProxySettings = true;
          recommendedGzipSettings = true;
          recommendedOptimisation = true;
          recommendedTlsSettings = true;
          virtualHosts."paper.rab.lol" = {
            forceSSL = true;
            enableACME = true;
            acmeRoot = null;
            locations."/".proxyPass = "http://localhost:28981";
            extraConfig = ''
              client_max_body_size 24G;
            '';
          };
        };

        security.acme.acceptTerms = true;
        security.acme.certs."paper.rab.lol" = {
          email = "nikodem@rabulinski.com";
          dnsProvider = "cloudflare";
          credentialsFile = config.age.secrets.rab-lol-cf.path;
        };
      };
  };
}
