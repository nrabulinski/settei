{ config, ... }:
{
  services.coturn = {
    enable = true;
    realm = "rab.lol";
    use-auth-secret = true;
    min-port = 50201;
    max-port = 65535;
    no-cli = true;
    cert = "${config.security.acme.certs."turn.rab.lol".directory}/fullchain.pem";
    pkey = "${config.security.acme.certs."turn.rab.lol".directory}/key.pem";
    static-auth-secret-file = config.age.secrets.coturn-secret.path;
  };
}
