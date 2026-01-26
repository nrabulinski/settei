{
  config.services.forgejo-runner = {
    hosts = [
      "ude"
      "youko"
      "kogata"
    ];
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
          age.secrets.forgejo-runner-token.file = ../secrets/forgejo-token.age;

          services.gitea-actions-runner = {
            package = pkgs.forgejo-runner;
            instances.default = {
              enable = true;
              name = config.networking.hostName;
              url = "https://git.rab.lol";
              tokenFile = config.age.secrets.forgejo-runner-token.path;
              hostPackages = lib.mkOptionDefault [
                pkgs.nix
              ];
              labels = [
                "native:host"
                "native-${pkgs.stdenv.hostPlatform.system}:host"
              ];
            };
          };
        };

        linux = lib.optionalAttrs isLinux {
          services.gitea-actions-runner = {
            instances.default = {
              settings = {
                container.network = "bridge";
              };
              labels = [
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
          age.secrets.forgejo-runner-token.owner = "_gitea-runner";
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
