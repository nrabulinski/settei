{ config, pkgs, ... }:
let
  continuwuity = pkgs.matrix-continuwuity.overrideAttrs (
    final: prev: {
      version = "26.9.1-unstable-2026-10-12";

      src = prev.src.override {
        tag = null;
        rev = "7da0ef6e2b3349b7c83b006a67b5854466dbf910";
        hash = "sha256-jyUFvwEP82yuuhfZ13ei9Syq62PC9fqlKFarHpQU2X8=";
      };

      cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
        inherit (final) pname version src;
        hash = "sha256-uJfKmqB83JFUq6K7YmGQpxNPOBLeGXOdg1nGhzyt1do=";
      };

      patches = [ ./continuwuity.patch ];
    }
  );
in
{
  services.matrix-continuwuity = {
    enable = true;
    package = continuwuity;
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
