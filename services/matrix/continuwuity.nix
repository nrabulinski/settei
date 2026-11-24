{ config, pkgs, ... }:
let
  rocksdb = pkgs.matrix-continuwuity.rocksdb.overrideAttrs (
    _final: prev: {
      version = "continuwuity-v0.5.0-unstable-2026-11-08";
      src = prev.src.override {
        rev = "722fa3219df4169610fda8962221a1ff74026fdb";
        hash = "sha256-ZuXXp83Hgj0B5v499CNxa9oNQUS/ZKYOAZEhmarUifc=";
      };

      postPatch = "";
    }
  );
  continuwuity = pkgs.matrix-continuwuity.overrideAttrs (
    final: prev: {
      version = "26.11.0-alpha.2";

      src = prev.src.override {
        hash = "sha256-M278MLqmjct+Vna1nwJ3Tkjxd4whuzNnuuoia+ecAXU=";
      };

      cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
        inherit (final) pname version src;
        hash = "sha256-4IKPv/B0uGf29Ajlset9VHvTkpkg1FbvZMvxMm0XOmA=";
      };

      inherit rocksdb;
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
