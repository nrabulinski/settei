{ config, pkgs, ... }:
let
  r = pkgs.fetchFromGitea {
    domain = "forgejo.ellis.link";
    owner = "continuwuation";
    repo = "rocksdb";
    rev = "10.10.fb";
    hash = "sha256-1ef75IDMs5Hba4VWEyXPJb02JyShy5k4gJfzGDhopRk=";
  };

  c = pkgs.fetchFromGitea {
    domain = "forgejo.ellis.link";
    owner = "continuwuation";
    repo = "continuwuity";
    rev = "aa7907241194fa90f0e316a24137eb8d4d91b15e";
    hash = "sha256-oHqWrqA8hyqxLoIAOw2nGXNd/9NfoQoOapZ7hppBV7U=";
  };

  fetchFromGitea = a: if a.repo == "continuwuity" then c else r;

  rustPlatform = pkgs.rustPlatform // {
    buildRustPackage =
      argsFn:
      pkgs.rustPlatform.buildRustPackage (
        (argsFn { })
        // {
          cargoHash = "sha256-9qnPIbSPLSz+ZJZZjJBURTp5nrgngK8rufdM65ZtiAM=";
        }
      );
  };
in
{
  services.matrix-continuwuity = {
    enable = true;
    package = pkgs.matrix-continuwuity.override {
      inherit rustPlatform fetchFromGitea;
    };
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
