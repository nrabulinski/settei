{
  config.services.kanidm =
    let
      port = 8443;
      domain = "auth.rabulinski.com";
    in
    {
      host = "kazuki";
      ports = [ port ];
      module =
        { config, pkgs, ... }:
        let
          cert = config.security.acme.certs.${domain};
        in
        {
          age.secrets.rabulinski-com-cf = {
            file = ../secrets/rabulinski-com-cf.age;
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
            enableServer = true;
            package = pkgs.kanidmWithSecretProvisioning;
            serverSettings = {
              bindaddress = "127.0.0.1:${toString port}";
              inherit domain;
              origin = "https://${domain}";
              trust_x_forward_for = true;
              tls_chain = "${cert.directory}/fullchain.pem";
              tls_key = "${cert.directory}/key.pem";
            };
            provision = {
              enable = true;
              idmAdminPasswordFile = config.age.secrets.kanidm-idm-admin-pass.path;
              adminPasswordFile = config.age.secrets.kanidm-admin-pass.path;
            };
          };

          systemd.services.kanidm.serviceConfig = {
            SupplementaryGroups = [ cert.group ];
          };

          users.users.nginx.extraGroups = [ "acme" ];
          networking.firewall.allowedTCPPorts = [
            80
            443
          ];

          services.nginx = {
            enable = true;
            recommendedProxySettings = true;
            recommendedGzipSettings = true;
            recommendedOptimisation = true;
            recommendedTlsSettings = true;
            virtualHosts."auth.rabulinski.com" = {
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
          };

          security.acme.certs.${domain} = {
            dnsProvider = "cloudflare";
            credentialsFile = config.age.secrets.rabulinski-com-cf.path;
            reloadServices = [ "kanidm" ];
          };
        };
    };
}
