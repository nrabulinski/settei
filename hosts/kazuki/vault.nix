{config, ...}: {
  age.secrets.vault-cert-env.file = ../../secrets/vault-cert-env.age;

  services.vaultwarden = {
    enable = true;
    config = {
      ROCKET_PORT = 60001;
    };
  };

  users.users.nginx.extraGroups = ["acme"];
  networking.firewall.allowedTCPPorts = [80 443 8448 2222];

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts."vault.rabulinski.com" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://vaultwarden";
      };
    };

    upstreams.vaultwarden.servers = {
      "localhost:${toString config.services.vaultwarden.config.ROCKET_PORT}" = {};
    };
  };

  security.acme.certs."valut.rabulinski.com" = {
    dnsProvider = "cloudflare";
    credentialsFile = config.age.secrets.vault-cert-env.path;
  };
}
