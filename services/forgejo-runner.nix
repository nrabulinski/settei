{
  config.services.forgejo-runner = {
    hosts = [
      "ude"
      "youko"
    ];
    module =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        age.secrets.forgejo-runner-token.file = ../secrets/forgejo-token.age;

        services.gitea-actions-runner = {
          package = pkgs.forgejo-runner;
          instances.default = {
            enable = true;
            name = config.networking.hostName;
            url = "https://git.rab.lol";
            tokenFile = config.age.secrets.forgejo-runner-token.path;
            settings = {
              container.network = "bridge";
            };
            hostPackages = lib.mkOptionDefault [
              pkgs.nix
            ];
            labels = [
              "ubuntu-latest:docker://node:16-bullseye"
              "ubuntu-22.04:docker://node:16-bullseye"
              "ubuntu-20.04:docker://node:16-bullseye"
              "ubuntu-18.04:docker://node:16-buster"
              "native:host"
              "native-${pkgs.system}:host"
            ];
          };
        };

        virtualisation.podman = {
          enable = true;
          defaultNetwork.settings.dns_enabled = true;
        };

        networking.firewall.trustedInterfaces = [ "podman+" ];
      };
  };
}
