{
  config,
  lib,
  inputs,
  ...
}:
{
  age.secrets.rab-lol-cf = {
    file = ../../secrets/rab-lol-cf.age;
    owner = config.services.nginx.user;
  };

  services.prometheus = {
    enable = true;
    scrapeConfigs =
      let
        nodeExporter = nixos: nixos.config.services.prometheus.exporters.node;
        configurations = lib.filterAttrs (
          _: nixos: (nodeExporter nixos).enable
        ) inputs.settei.nixosConfigurations;
      in
      lib.mapAttrsToList (
        name: nixos:
        let
          target = "${name}:${toString (nodeExporter nixos).port}";
        in
        {
          job_name = "${name}-node";
          static_configs = [
            {
              targets = [ target ];
              labels.${name} = target;
            }
          ];
        }
      ) configurations;
  };

  services.grafana = {
    enable = true;
    settings.server = {
      http_port = 3030;
      root_url = "https://monitor.rab.lol";
    };
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    virtualHosts."monitor.rab.lol" = {
      forceSSL = true;
      enableACME = true;
      acmeRoot = null;
      locations."/" = {
        proxyPass = "http://grafana";
        proxyWebsockets = true;
      };
    };

    upstreams.grafana.servers =
      let
        inherit (config.services.grafana.settings.server) http_addr http_port;
      in
      {
        "${http_addr}:${toString http_port}" = { };
      };
  };

  security.acme.certs."monitor.rab.lol" = {
    dnsProvider = "cloudflare";
    credentialsFile = config.age.secrets.rab-lol-cf.path;
  };
}
