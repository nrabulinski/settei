{ config, ... }:
{
  services.matrix-continuwuity = {
    enable = true;
    settings.global = {
      address = [ "127.0.0.1" ];
      port = [ 6168 ];
      server_name = "rab.lol";
      allow_registration = false;
      max_request_size = 1024 * 1024 * 1024;
      well_known = {
        client = "https://matrix.rab.lol";
        server = "matrix.rab.lol:443";
      };
      turn_uris = [
        "turn:turn.rab.lol?transport=udp"
        "turn:turn.rab.lol?transport=tcp"
        "turns:turn.rab.lol?transport=udp"
        "turns:turn.rab.lol?transport=tcp"
      ];
      turn_secret_file = config.age.secrets.coturn-secret.path;
      turn_ttl = 86400;
    };
  };
}
