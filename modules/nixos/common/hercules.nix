{
  config,
  pkgs,
  lib,
  ...
}: {
  _file = ./hercules.nix;

  options.common.hercules.enable = lib.mkEnableOption "Enables hercules-ci-agent with my configuration";

  config = lib.mkIf config.common.hercules.enable {
    age.secrets.hercules-token = {
      file = ../../secrets/hercules-token.age;
      owner = config.systemd.services.hercules-ci-agent.serviceConfig.User;
    };

    services.hercules-ci-agent = {
      enable = true;
      settings = {
        clusterJoinTokenPath = config.age.secrets.hercules-token.path;
        concurrentTasks = lib.mkDefault 4;
        binaryCachesPath = pkgs.writeText "empty-caches.json" "{}";
      };
    };
  };
}
