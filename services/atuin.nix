{
  config.services.atuin = {
    host = "kazuki";
    ports = [ ]; # Atuin server is running in its own container
    module = _: {
      settei.containers.atuin.config = {
        services.atuin = {
          enable = true;
          host = "0.0.0.0";
          port = 8888;
          openFirewall = true;
        };
      };

      services.nginx.enable = true;
      services.nginx.virtualHosts."atuin.rab.lol" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;

      };
    };
  };
}
