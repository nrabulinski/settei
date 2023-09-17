{
  config,
  self,
  inputs,
  lib,
  ...
}: {
  builders = {
    nixos = name: module: let
      defaultOptions = {
        username,
        inputs',
        lib,
        ...
      }: {
        _file = ./default.nix;

        settei = {
          username = lib.mkDefault "niko";
          sane-defaults = {
            enable = lib.mkDefault true;
            allSshKeys = config.assets.sshKeys.user;
          };
          flake-qol = {
            enable = true;
            inputs = inputs // {settei = self;};
          };
          user = {
            enable = true;
            config = {
              home.packages = lib.attrValues inputs'.settei.packages;
            };
          };
        };

        time.timeZone = lib.mkDefault "Europe/Warsaw";
        i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
      };
    in
      inputs.nixpkgs.lib.nixosSystem {
        modules = [
          inputs.agenix.nixosModules.age
          inputs.disko.nixosModules.disko
          inputs.mailserver.nixosModules.default
          inputs.home-manager.nixosModules.home-manager
          inputs.hercules-ci-agent.nixosModules.agent-service
          self.nixosModules.settei
          self.nixosModules.common
          defaultOptions
          module
        ];
        specialArgs.configurationName = name;
      };
  };

  imports = [
    ./kazuki
    ./hijiri-vm
    # ./legion
    ./installer
  ];
}
