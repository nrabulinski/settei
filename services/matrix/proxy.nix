{ lib, config, ... }:
{
  services.nginx.enable = true;
  services.nginx.virtualHosts."rab.lol" = {
    forceSSL = true;
    enableACME = true;
    acmeRoot = null;
    locations."/.well-known/matrix" = {
      proxyPass = "http://continuwuity$request_uri";
    };
  };
  services.nginx.virtualHosts."matrix.rab.lol" = {
    listen =
      let
        ports = [
          { port = 80; }
          {
            port = 443;
            ssl = true;
          }
          {
            port = 8448;
            ssl = true;
          }
        ];
      in
      lib.flatten (
        map (port: [
          (port // { addr = "0.0.0.0"; })
          (port // { addr = "[::0]"; })
        ]) ports
      );
    forceSSL = true;
    enableACME = true;
    acmeRoot = null;
    locations."/" = {
      proxyPass = "http://continuwuity";
      proxyWebsockets = true;
    };
    extraConfig = ''
      proxy_buffering off;
      client_max_body_size 1G;
    '';
  };
  services.nginx.upstreams.continuwuity.servers = {
    "localhost:${toString config.services.matrix-continuwuity.settings.global.port}" = { };
  };
}
