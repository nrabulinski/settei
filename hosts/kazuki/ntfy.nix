{config, ...}: {
  age.secrets.nrab-lol-cf = {
    file = ../../secrets/nrab-lol-cf.age;
    owner = config.services.nginx.user;
  };

  services.ntfy-sh = {
    enable = true;
    settings = {
      base-url = "ntfy.nrab.lol";
      listen-http = "127.0.0.1:9800";
      behind-proxy = true;
      upstream-base-url = "https://ntfy.sh";
      auth-default-access = "deny-all";
    };
  };

  users.users.nginx.extraGroups = ["acme"];
  networking.firewall.allowedTCPPorts = [80 443];

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    virtualHosts."ntfy.nrab.lol" = {
      forceSSL = true;
      enableACME = true;
      acmeRoot = null;
      locations."/" = {
        proxyPass = "http://ntfy";
        proxyWebsockets = true;
      };
    };

    upstreams.ntfy.servers = {
      "localhost:9800" = {};
    };
  };

  security.acme.certs."ntfy.nrab.lol" = {
    dnsProvider = "cloudflare";
    credentialsFile = config.age.secrets.nrab-lol-cf.path;
  };
}
