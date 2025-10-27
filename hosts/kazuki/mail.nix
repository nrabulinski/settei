{ config, ... }:
{
  # nix shell nixpkgs#apacheHttpd -c htpasswd -nbB "" "super secret password" | cut -d: -f2
  age.secrets = {
    leet-nrab-lol.file = ../../secrets/leet-nrab-lol-pass.age;
    alert-nrab-lol.file = ../../secrets/alert-nrab-lol-pass.age;
  };

  users.users.nginx.extraGroups = [ "acme" ];
  networking.firewall.allowedTCPPorts = [
    80
    443
    8448
    2222
  ];

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

    certificateScheme = "acme-nginx";

    stateVersion = 3;
  };
}
