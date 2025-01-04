{ isLinux }:
{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption types;
  github-runner-user = "github-runner";

  cfg = config.settei.github-runner;

  sharedConfig = {
    age.secrets.github-token = {
      file = ../../../secrets/github-token.age;
      owner = github-runner-user;
    };
  };

  linuxConfig = lib.optionalAttrs isLinux {
    services.github-runners = lib.pipe cfg.runners [
      (lib.mapAttrsToList (
        name: cfg:
        lib.genList (
          i:
          lib.nameValuePair "${name}-${toString i}" {
            enable = true;
            tokenFile = config.age.secrets.github-token.path;
            inherit (cfg) url;
            name = "${cfg.name}-${toString i}";
            user = github-runner-user;
            serviceOverrides = {
              DynamicUser = false;
            };
            extraLabels = [ "nix" ];
          }
        ) cfg.instances
      ))
      lib.flatten
      lib.listToAttrs
    ];

    users = {
      users.${github-runner-user} = {
        isSystemUser = true;
        group = github-runner-user;
      };
      groups.${github-runner-user} = { };
    };
  };

  darwinConfig = lib.optionalAttrs (!isLinux) {
    warnings = lib.singleton "settei.github-runner doesn't do anything on darwin yet";
  };
in
{
  _file = ./github-runner.nix;

  options.settei.github-runner = {
    enable = lib.mkEnableOption "using this machine as a self-hosted github runner";
    runners = mkOption {
      type =
        with types;
        attrsOf (
          submodule (
            { name, ... }:
            {
              options = {
                name = mkOption {
                  type = types.str;
                  default = "${name}-${config.networking.hostName}";
                };
                url = mkOption { type = types.str; };
                instances = mkOption {
                  type = types.int;
                  default = 1;
                };
              };
            }
          )
        );
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      sharedConfig
      linuxConfig
      darwinConfig
    ]
  );
}
