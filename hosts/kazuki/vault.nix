{ config, ... }:
{
  age.secrets.rabulinski-com-cf = {
    file = ../../secrets/rabulinski-com-cf.age;
    owner = config.services.nginx.user;
  };

  services.vaultwarden = {
    enable = true;
    config = {
      ROCKET_PORT = 60001;
    };
  };

  users.users.nginx.extraGroups = [ "acme" ];
  networking.firewall.allowedTCPPorts = [
    80
    443
    8448
    2222
  ];

  services.nginx.enable = true;
  services.nginx.virtualHosts."vault.rabulinski.com" = {
    forceSSL = true;
    enableACME = true;
    acmeRoot = null;
    locations."/" = {
      proxyPass = "http://vaultwarden";
      proxyWebsockets = true;
    };
  };

  services.nginx.upstreams.vaultwarden.servers = {
    "localhost:${toString config.services.vaultwarden.config.ROCKET_PORT}" = { };
  };

  security.acme.certs."vault.rabulinski.com" = {
    dnsProvider = "cloudflare";
    credentialsFile = config.age.secrets.rabulinski-com-cf.path;
  };
}
