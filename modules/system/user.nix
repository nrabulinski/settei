{
  config,
  options,
  lib,
  inputs,
  configurationName,
  ...
}@args:
let
  hasHomeManager = options ? home-manager;
  cfg = config.settei.user;
  inherit (config.settei) username;
in
{
  _file = ./user.nix;

  options.settei.user = with lib; {
    enable = mkEnableOption "User-specific configuration" // {
      default = true;
    };
    config = mkOption {
      type = types.deferredModule;
      default = { };
    };
    extraArgs = mkOption {
      type = types.attrs;
      default = { };
    };
  };

  config =
    let
      hmConfig = lib.optionalAttrs hasHomeManager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = {
          inherit (args) inputs inputs';
          machineName = configurationName;
        } // cfg.extraArgs;

        home-manager.users.${username} = {
          _file = ./user.nix;

          imports = [
            inputs.settei.homeModules.settei
            cfg.config
          ];

          home = {
            inherit username;
            homeDirectory = config.users.users.${username}.home;
            stateVersion = "22.05";
          };
        };
      };
    in
    lib.mkIf cfg.enable (
      lib.mkMerge [
        {
          assertions = [
            {
              assertion = hasHomeManager;
              message = "Home-manager module has to be imported before enabling settei.user";
            }
          ];
        }
        hmConfig
      ]
    );
}
