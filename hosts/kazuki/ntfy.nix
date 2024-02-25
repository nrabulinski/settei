{
  config,
  lib,
  pkgs,
  ...
}:
{
  age.secrets.nrab-lol-cf = {
    file = ../../secrets/nrab-lol-cf.age;
    owner = config.services.nginx.user;
  };
  age.secrets.ntfy-niko-pass = {
    file = ../../secrets/ntfy-niko-pass.age;
    owner = config.services.ntfy-sh.user;
  };
  age.secrets.ntfy-alert-pass = {
    file = ../../secrets/ntfy-alert-pass.age;
    owner = config.services.ntfy-sh.user;
  };

  services.ntfy-sh = {
    enable = true;
    settings = {
      base-url = "https://ntfy.nrab.lol";
      listen-http = "127.0.0.1:9800";
      behind-proxy = true;
      upstream-base-url = "https://ntfy.sh";
      auth-default-access = "deny-all";
    };
  };

  systemd.services.ntfy-sh.postStart =
    let
      ntfy = lib.getExe' config.services.ntfy-sh.package "ntfy";
      script = pkgs.writeShellScript "ntfy-setup-users.sh" ''
        ${ntfy} access everyone '*' deny

        if ! ${ntfy} user list | grep -q 'user alert'; then
          NTFY_PASSWORD="$(cat ${config.age.secrets.ntfy-alert-pass.path})" \
            ${ntfy} user add alert
          ${ntfy} access alert '*' write-only
        fi

        if ! ${ntfy} user list | grep -q 'user niko'; then
          NTFY_PASSWORD="$(cat ${config.age.secrets.ntfy-niko-pass.path})" \
            ${ntfy} user add niko
          ${ntfy} access niko '*' read-only
        fi
      '';
    in
    toString script;

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
      "localhost:9800" = { };
    };
  };

  security.acme.certs."ntfy.nrab.lol" = {
    dnsProvider = "cloudflare";
    credentialsFile = config.age.secrets.nrab-lol-cf.path;
  };
}
