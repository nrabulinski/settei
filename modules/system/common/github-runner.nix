{isLinux}: {
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkOption types;
  github-runner-user = "github-runner";

  cfg = config.common.github-runner;

  sharedConfig = {
    age.secrets.github-token = {
      file = ../../../secrets/github-token.age;
      owner = github-runner-user;
    };
  };

  linuxConfig = lib.optionalAttrs isLinux {
    services.github-runners =
      lib.mapAttrs (name: cfg: {
        enable = true;
        tokenFile = config.age.secrets.github-token.path;
        inherit (cfg) name url;
        ephemeral = true;
        user = github-runner-user;
        serviceOverrides = {
          DynamicUser = false;
        };
        extraLabels = ["nix"];
      })
      cfg.runners;

    users = {
      users.${github-runner-user} = {
        isSystemUser = true;
        group = github-runner-user;
      };
      groups.${github-runner-user} = {};
    };
  };

  darwinConfig = lib.optionalAttrs (!isLinux) {
    warnings = lib.singleton "common.github-runner doesn't do anything on darwin yet";
  };
in {
  _file = ./github-runner.nix;

  options.common.github-runner = {
    enable = lib.mkEnableOption "using this machine as a self-hosted github runner";
    runners = mkOption {
      type = with types;
        attrsOf (submodule ({name, ...}: {
          options = {
            name = mkOption {
              type = types.str;
              default = "${name}-${config.networking.hostName}";
            };
            url = mkOption {
              type = types.str;
            };
          };
        }));
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    sharedConfig
    linuxConfig
    darwinConfig
  ]);
}
