{
  config.services.immich = {
    host = "youko";
    ports = [
      # Web UI
      2283
      # Immich ML
      3003
    ];
    module = {
      services.immich = {
        enable = true;
        mediaLocation = "/media/immich";
        accelerationDevices = [ "/dev/dri/renderD128" ];
        # TODO: Declarative config
        settings = null;
      };

      services.nginx.virtualHosts."gallery.rab.lol" = {
        forceSSL = true;
        useACMEHost = "_wildcard.rab.lol";
        locations."/" = {
          proxyPass = "http://localhost:2283";
          proxyWebsockets = true;
        };
        extraConfig = ''
          proxy_request_buffering off;
          client_max_body_size 24G;
        '';
      };
    };
  };
}
