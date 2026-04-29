{
  config.services.kanidm =
    let
      port = 8443;
      ldapPort = 9636;
      domain = "auth.rab.lol";
    in
    {
      host = "kazuki";
      ports = [
        port
        ldapPort
      ];
      module =
        { config, pkgs, ... }:
        let
          cert = config.security.acme.certs.${domain};
        in
        {
          age.secrets.rab-lol-cf = {
            file = ../secrets/rab-lol-cf.age;
            owner = config.services.nginx.user;
          };
          age.secrets.kanidm-admin-pass = {
            file = ../secrets/kanidm-admin-pass.age;
            owner = "kanidm";
          };
          age.secrets.kanidm-idm-admin-pass = {
            file = ../secrets/kanidm-idm-admin-pass.age;
            owner = "kanidm";
          };

          services.kanidm = {
            server.enable = true;
            package = pkgs.kanidmWithSecretProvisioning_1_9;
            server.settings = {
              bindaddress = "127.0.0.1:${toString port}";
              inherit domain;
              origin = "https://${domain}";
              tls_chain = "${cert.directory}/fullchain.pem";
              tls_key = "${cert.directory}/key.pem";
              ldapbindaddress = "[::]:${toString ldapPort}";
            };
            provision = {
              enable = true;
              autoRemove = false;
              idmAdminPasswordFile = config.age.secrets.kanidm-idm-admin-pass.path;
              adminPasswordFile = config.age.secrets.kanidm-admin-pass.path;

              groups."git.access".overwriteMembers = false;
              groups."git.admins".overwriteMembers = false;
              groups."radius.access".overwriteMembers = false;

              systems.oauth2.forgejo = {
                displayName = "Forgejo";
                originUrl = "https://git.rab.lol/user/oauth2/kanidm/callback";
                originLanding = "https://git.rab.lol/";
                scopeMaps."git.access" = [
                  "openid"
                  "email"
                  "profile"
                ];
                preferShortUsername = true;
                claimMaps.groups = {
                  joinType = "array";
                  valuesByGroup."git.admins" = [ "admin" ];
                };
              };

              persons.niko = {
                displayName = "niko";
                legalName = "Nikodem Rabuliński";
                mailAddresses = [
                  "n@rab.lol"
                ];
                groups = [
                  "git.access"
                  "git.admins"
                  "radius.access"
                ];
              };
            };
          };

          systemd.services.kanidm.serviceConfig = {
            SupplementaryGroups = [ cert.group ];
          };

          networking.firewall.allowedTCPPorts = [
            80
            443
            ldapPort
          ];

          services.nginx.enable = true;
          services.nginx.virtualHosts.${domain} = {
            forceSSL = true;
            enableACME = true;
            acmeRoot = null;
            locations."/" = {
              proxyPass = "https://localhost:${toString port}";
              proxyWebsockets = true;
              extraConfig = ''
                proxy_ssl_verify off;
                proxy_ssl_name ${domain};
              '';
            };
          };

          security.acme.certs.${domain} = {
            dnsProvider = "cloudflare";
            credentialFiles.CF_DNS_API_TOKEN_FILE = config.age.secrets.rab-lol-cf.path;
            reloadServices = [ "kanidm" ];
          };
        };
    };
}
