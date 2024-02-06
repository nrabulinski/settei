{isLinux}: {
  config,
  pkgs,
  lib,
  ...
}: let
  options = {
    common.hercules.enable = lib.mkEnableOption "Enables hercules-ci-agent with my configuration";
  };

  herculesUser =
    if isLinux
    then config.systemd.services.hercules-ci-agent.serviceConfig.User
    else config.launchd.daemons.hercules-ci-agent.serviceConfig.UserName;
in {
  _file = ./hercules.nix;

  inherit options;

  config =
    lib.mkIf false
    /*
    config.common.hercules.enable
    */
    {
      age.secrets.hercules-token = {
        file = ../../../secrets/hercules-token.age;
        owner = herculesUser;
      };
      age.secrets.hercules-cache = {
        file = ../../../secrets/hercules-cache.age;
        owner = herculesUser;
      };
      age.secrets.hercules-secrets = {
        file = ../../../secrets/hercules-secrets.age;
        owner = herculesUser;
      };

      services.hercules-ci-agent = {
        enable = true;
        settings = {
          clusterJoinTokenPath = config.age.secrets.hercules-token.path;
          concurrentTasks = lib.mkDefault 4;
          binaryCachesPath = config.age.secrets.hercules-cache.path;
          secretsJsonPath = config.age.secrets.hercules-secrets.path;
        };
      };
    };
}
