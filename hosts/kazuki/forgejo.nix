{ config, ... }:
{
  age.secrets.rab-lol-cf = {
    file = ../../secrets/rab-lol-cf.age;
    owner = config.services.nginx.user;
  };

  services.forgejo = {
    enable = true;
    settings = {
      server = {
        DOMAIN = "git.rab.lol";
        ROOT_URL = "https://git.rab.lol/";
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
    repositoryRoot = "/storage-box/forgejo/repos";
    lfs = {
      enable = true;
      contentDir = "/storage-box/forgejo/lfs";
    };
  };

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
}
