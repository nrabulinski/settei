{
  config,
  lib,
  ...
}: {
  _file = ./hercules.nix;

  options.common.hercules.enable = lib.mkEnableOption "Enables hercules-ci-agent with my configuration";

  config = let
    herculesUser = config.systemd.services.hercules-ci-agent.serviceConfig.User;
  in
    lib.mkIf config.common.hercules.enable {
      age.secrets.hercules-token = {
        file = ../../../secrets/hercules-token.age;
        owner = herculesUser;
      };
      age.secrets.hercules-cache = {
        file = ../../../secrets/hercules-cache.age;
        owner = herculesUser;
      };

      services.hercules-ci-agent = {
        enable = true;
        settings = {
          clusterJoinTokenPath = config.age.secrets.hercules-token.path;
          concurrentTasks = lib.mkDefault 4;
          binaryCachesPath = config.age.secrets.hercules-cache.path;
        };
      };
    };
}
