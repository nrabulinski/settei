{
  config.services.forgejo = {
    host = "kazuki";
    ports = [
      3000
      3001
    ];
    module =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        cfg = config.services.forgejo;
        imgDir = pkgs.runCommand "forgejo-img-dir" { } ''
          cp -R ${../assets/forgejo} "$out"
        '';
        go-away-policy = pkgs.runCommand "go-away-policy" { } ''
          cp -R "${pkgs.go-away.src}/examples" "$out"
        '';
      in
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
            "git.timeout" = {
              MIGRATE = 6000;
              MIRROR = 3000;
            };
            repo-archive.PATH = "/forgejo/archive";
            "actions.artifacts".PATH = "/forgejo/artifacts";
          };
          repositoryRoot = "/forgejo/repos";
          lfs = {
            enable = true;
            contentDir = "/forgejo/lfs";
          };
        };

        systemd.services.forgejo.serviceConfig.ReadWritePaths = [
          cfg.settings.repo-archive.PATH
          cfg.settings."actions.artifacts".PATH
        ];

        systemd.tmpfiles.rules = [
          "d '${cfg.customDir}/public' 0750 ${cfg.user} ${cfg.group} - -"
          "d '${cfg.customDir}/public/assets' 0750 ${cfg.user} ${cfg.group} - -"
          "L+ '${cfg.customDir}/public/assets/img' - - - - ${imgDir}"

          "d '${cfg.settings.repo-archive.PATH}' 0750 ${cfg.user} ${cfg.group} - -"
          "z '${cfg.settings.repo-archive.PATH}' 0750 ${cfg.user} ${cfg.group} - -"

          "d '${cfg.settings."actions.artifacts".PATH}' 0750 ${cfg.user} ${cfg.group} - -"
          "z '${cfg.settings."actions.artifacts".PATH}' 0750 ${cfg.user} ${cfg.group} - -"
        ];

        # TODO: Make this into a module?
        systemd.services.go-away-forgejo = {
          wantedBy = [ "multi-user.target" ];
          script = ''
            ${lib.getExe pkgs.go-away} \
              --bind "127.0.0.1:3001" \
              --backend "git.rab.lol=http://127.0.0.1:3000" \
              --client-ip-header "X-Real-Ip" \
              --challenge-template forgejo \
              --policy "${go-away-policy}/forgejo.yml" \
              --policy-snippets "${go-away-policy}/snippets/"
          '';
        };

        settei.iocaine.enable = true;
        settei.iocaine.protectedHosts."git.rab.lol" = {
          locations."/" = {
            proxyPass = "http://127.0.0.1:3001";
            proxyWebsockets = true;
          };
          extraNginxConfig = {
            forceSSL = true;
            enableACME = true;
            acmeRoot = null;
            # TODO: Allow archives from mirrors again?
            locations."~* ^/(?:api/v1/repos/)?mirrors/[^/]+/archive(?:/|$)".return = 403;
          };
        };

        security.acme.certs."git.rab.lol" = {
          dnsProvider = "cloudflare";
          credentialFiles.CF_DNS_API_TOKEN_FILE = config.age.secrets.rab-lol-cf.path;
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
