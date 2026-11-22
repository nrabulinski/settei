{
  config.services.forgejo-runner = {
    hosts = [
      "youko"
      "kanade"
      "hijiri"
    ];
    hostModule.youko = {
      age.secrets.forgejo-runner-token.file = ../secrets/forgejo-token-youko.age;
      services.forgejo-runner.instances.default.settings.server.connections.default.uuid =
        "2124d14e-7be4-48e8-bdf4-1bd373f19411";
    };
    hostModule.kanade = {
      age.secrets.forgejo-runner-token.file = ../secrets/forgejo-token-kanade.age;
      services.forgejo-runner.instances.default.settings.server.connections.default.uuid =
        "f738b35f-0d8a-42b4-a9fb-f86f804ae70e";
    };
    hostModule.hijiri = {
      age.secrets.forgejo-runner-token.file = ../secrets/forgejo-token-hijiri.age;
      services.forgejo-runner.instances.default.settings.server.connections.default.uuid =
        "ebd0cd56-05f2-4a0d-bb8d-785e0a8d7b8b";
    };
    module =
      {
        config,
        lib,
        pkgs,
        isLinux,
        ...
      }:
      let
        shared = {
          services.forgejo-runner = {
            instances.default = {
              enable = true;
              hostPackages = lib.mkOptionDefault [
                {
                  type = "derivation";
                  outPath = "/run/wrappers";
                }
                config.nix.package
              ];
              settings.runner.labels = [
                "native:host"
                "native-${pkgs.stdenv.hostPlatform.system}:host"
              ];
              settings.server.connections.default = {
                url = "https://git.rab.lol";
                uuid = lib.mkDefault (throw "UUID of the runner must be set");
              };
              secrets.server.connections.default.token_url = config.age.secrets.forgejo-runner-token.path;
            };
          };
        };

        linux = lib.optionalAttrs isLinux {
          services.forgejo-runner = {
            instances.default = {
              settings = {
                container.network = "bridge";
              };
              settings.runner.labels = [
                "ubuntu-latest:docker://node:16-bullseye"
                "ubuntu-22.04:docker://node:16-bullseye"
                "ubuntu-20.04:docker://node:16-bullseye"
                "ubuntu-18.04:docker://node:16-buster"
              ];
            };
          };

          virtualisation.podman = {
            enable = true;
            defaultNetwork.settings.dns_enabled = true;
          };

          networking.firewall.trustedInterfaces = [ "podman+" ];
        };

        darwin = lib.optionalAttrs (!isLinux) {
          age.secrets.forgejo-runner-token.owner = "_forgejo-runner";
        };
      in
      {
        config = lib.mkMerge [
          shared
          linux
          darwin
        ];
      };
  };
}
