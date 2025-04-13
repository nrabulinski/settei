{
  services.forgejo = {
    host = "kazuki";
    ports = [ 3000 ];
    config =
      { config, pkgs, ... }:
      {
        age.secrets.rab-lol-cf = {
          file = ../secrets/rab-lol-cf.age;
          owner = config.services.nginx.user;
        };

        services.forgejo = {
          enable = true;
          package = pkgs.forgejo;
          settings = {
            server = {
              DOMAIN = "git.rab.lol";
              ROOT_URL = "https://git.rab.lol/";
            };
            security = {
              DISABLE_GIT_HOOKS = false;
            };
            oauth2_client = {
              REGISTER_EMAIL_CONFIRM = false;
              ENABLE_AUTO_REGISTRATION = true;
              ACCOUNT_LINKING = "auto";
              UPDATE_AVATAR = true;
            };
            service = {
              DISABLE_REGISTRATION = false;
              ALLOW_ONLY_INTERNAL_REGISTRATION = false;
              ALLOW_ONLY_EXTERNAL_REGISTRATION = true;
            };
            session = {
              SESSION_LIFE_TIME = 86400 * 30;
            };
            federation.ENABLED = true;
          };
          repositoryRoot = "/forgejo/repos";
          lfs = {
            enable = true;
            contentDir = "/forgejo/lfs";
          };
        };

        systemd.tmpfiles.rules =
          let
            cfg = config.services.forgejo;
            imgDir = pkgs.runCommand "forgejo-img-dir" { } ''
              cp -R ${../assets/forgejo} "$out"
            '';
          in
          [
            "d '${cfg.customDir}/public' 0750 ${cfg.user} ${cfg.group} - -"
            "d '${cfg.customDir}/public/assets' 0750 ${cfg.user} ${cfg.group} - -"
            "L+ '${cfg.customDir}/public/assets/img' - - - - ${imgDir}"
          ];

        services.nginx = {
          enable = true;
          recommendedProxySettings = true;
          recommendedGzipSettings = true;
          recommendedOptimisation = true;
          recommendedTlsSettings = true;
          virtualHosts."git.rab.lol" = {
            forceSSL = true;
            enableACME = true;
            acmeRoot = null;
            locations."/" = {
              proxyPass = "http://127.0.0.1:3000";
              extraConfig = ''
                proxy_set_header Connection $http_connection;
                proxy_set_header Upgrade $http_upgrade;
              '';
            };
          };
        };

        users.users.nginx.extraGroups = [ "acme" ];
        security.acme.acceptTerms = true;
        security.acme.certs."git.rab.lol" = {
          dnsProvider = "cloudflare";
          credentialsFile = config.age.secrets.rab-lol-cf.path;
          email = "nikodem@rabulinski.com";
        };

        fileSystems."/forgejo" = {
          device = "/dev/disk/by-label/forgejo";
          fsType = "btrfs";
          options = [
            "compress=zstd"
            "noatime"
          ];
        };
      };
  };
}
