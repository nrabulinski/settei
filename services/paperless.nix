{
  config.services.paperless = {
    host = "youko";
    ports = [ 28981 ];
    module =
      { config, pkgs, ... }:
      {
        age.secrets.rab-lol-cf = {
          file = ../secrets/rab-lol-cf.age;
          owner = config.services.nginx.user;
        };
        age.secrets.paperless-pass = {
          file = ../secrets/paperless-pass.age;
          owner = config.services.paperless.user;
        };

        services.paperless =
          let
            # Hacky way to override paperless package,
            # as the module always calls override on it.
            package' = pkgs.paperless-ngx.override {
              tesseract5 = pkgs.paperless-ngx.tesseract5.override {
                enableLanguages = [
                  "equ"
                  "osd"
                  "eng"
                  "pol"
                  "jpn"
                ];
              };
            };
            package = package'.overridePythonAttrs (prev: {
              disabledTests = prev.disabledTests or [ ] ++ [
                "test_filters"
              ];
            });
          in
          {
            enable = true;
            package = {
              type = "derivation";
              override = _: package;
            };
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
              PAPERLESS_URL = "https://paper.rab.lol";
            };
          };

        services.nginx.enable = true;
        services.nginx.virtualHosts."paper.rab.lol" = {
          forceSSL = true;
          enableACME = true;
          acmeRoot = null;
          locations."/".proxyPass = "http://localhost:28981";
          extraConfig = ''
            client_max_body_size 24G;
          '';
        };

        security.acme.certs."paper.rab.lol" = {
          email = "nikodem@rabulinski.com";
          dnsProvider = "cloudflare";
          credentialFiles.CF_DNS_API_TOKEN_FILE = config.age.secrets.rab-lol-cf.path;
        };
      };
  };
}
