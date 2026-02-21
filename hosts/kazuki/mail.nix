{ config, ... }:
{
  # nix shell nixpkgs#apacheHttpd -c htpasswd -nbB "" "super secret password" | cut -d: -f2
  age.secrets = {
    nrab-lol-cf = {
      file = ../../secrets/nrab-lol-cf.age;
      owner = config.services.nginx.user;
    };

    leet-nrab-lol.file = ../../secrets/leet-nrab-lol-pass.age;
    alert-nrab-lol.file = ../../secrets/alert-nrab-lol-pass.age;
  };

  mailserver = {
    enable = true;
    fqdn = "mail.nrab.lol";
    domains = [
      "nrab.lol"
      "rab.lol"
    ];
    lmtpSaveToDetailMailbox = "no";
    recipientDelimiter = "+-";

    loginAccounts = {
      "1337@nrab.lol" = {
        hashedPasswordFile = config.age.secrets.leet-nrab-lol.path;
        aliases = [ "n@rab.lol" ];
      };
      "alert@nrab.lol" = {
        hashedPasswordFile = config.age.secrets.alert-nrab-lol.path;
        sendOnly = true;
        sendOnlyRejectMessage = "";
      };
    };

    x509.useACMEHost = config.mailserver.fqdn;

    stateVersion = 3;
  };

  security.acme.certs.${config.mailserver.fqdn} = {
    dnsProvider = "cloudflare";
    credentialsFile = config.age.secrets.nrab-lol-cf.path;
  };
}
