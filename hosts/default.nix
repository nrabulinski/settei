{
  config,
  self,
  inputs,
  lib,
  ...
}: {
  imports = [
    ./kazuki
    ./hijiri-vm
    ./hijiri
    ./legion
    # TODO: Custom installer ISO
    # ./installer
  ];

  builders = let
    sharedOptions = {
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
            home.packages = let
              wrappers = lib.attrValues inputs'.settei.packages;
              extraPkgs = [inputs'.nh.packages.default];
            in
              wrappers ++ extraPkgs;

            programs.git.enable = true;
            home.sessionVariables.EDITOR = "hx";
          };
        };
      };

      time.timeZone = lib.mkDefault "Europe/Warsaw";
    };
  in {
    nixos = name: module: let
      defaultOptions = {
        _file = ./default.nix;

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
          sharedOptions
          defaultOptions
          module
        ];
        specialArgs.configurationName = name;
      };

    darwin = name: module: let
      defaultOptions = {
        _file = ./default.nix;
      };
    in
      inputs.darwin.lib.darwinSystem {
        modules = [
          inputs.agenix.darwinModules.age
          inputs.home-manager.darwinModules.home-manager
          inputs.hercules-ci-agent.darwinModules.agent-service
          self.darwinModules.settei
          sharedOptions
          defaultOptions
          module
        ];
        specialArgs.configurationName = name;
      };
  };
}
