{ config, inputs, ... }:
{
  age.secrets.rabulinski-com-cf = {
    file = ../../secrets/rabulinski-com-cf.age;
    owner = config.services.nginx.user;
  };

  settei.containers.zitadel.config =
    { config, ... }:
    {
      imports = [ inputs.agenix.nixosModules.age ];
      age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      age.secrets.zitadel-master = {
        file = ../../secrets/zitadel-master.age;
        owner = config.services.zitadel.user;
      };

      services.zitadel = {
        enable = true;
        masterKeyFile = config.age.secrets.zitadel-master.path;
        settings = {
          Port = 8080;
          Database.postgres = {
            Host = "/var/run/postgresql/";
            Port = 5432;
            Database = "zitadel";
            User = {
              Username = "zitadel";
              SSL.Mode = "disable";
            };
            Admin = {
              Username = "zitadel";
              SSL.Mode = "disable";
              ExistingDatabase = "zitadel";
            };
          };
          ExternalDomain = "zi.rabulinski.com";
          ExternalPort = 443;
          ExternalSecure = true;
        };
        steps.FirstInstance = {
          InstanceName = "zi";
          Org = {
            Name = "ZI";
            Human = {
              UserName = "nikodem@rabulinski.com";
              FirstName = "Nikodem";
              LastName = "Rabulinski";
              Email.Verified = true;
              Password = "Password1!";
              PasswordChangeRequired = true;
            };
          };
          LoginPolicy.AllowRegister = false;
        };
        openFirewall = true;
      };
      systemd.services.zitadel = {
        requires = [ "postgresql.service" ];
        after = [ "postgresql.service" ];
      };

      services.postgresql = {
        enable = true;
        enableJIT = true;
        ensureDatabases = [ "zitadel" ];
        ensureUsers = [
          {
            name = "zitadel";
            ensureDBOwnership = true;
            ensureClauses.login = true;
            ensureClauses.superuser = true;
          }
        ];
      };
    };

  users.users.nginx.extraGroups = [ "acme" ];
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  services.nginx.enable = true;
  services.nginx.virtualHosts."zi.rabulinski.com" = {
    forceSSL = true;
    enableACME = true;
    acmeRoot = null;
    locations."/" = {
      extraConfig = ''
        grpc_pass grpc://${config.settei.containers.zitadel.localAddress}:8080;
        grpc_set_header Host $host:$server_port;
      '';
    };
  };

  security.acme.certs."zi.rabulinski.com" = {
    dnsProvider = "cloudflare";
    credentialsFile = config.age.secrets.rabulinski-com-cf.path;
  };
}
