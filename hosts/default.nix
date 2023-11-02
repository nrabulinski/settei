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
    ./ude
  ];

  builders = let
    # FIXME: Move to common
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
          tailnet = "discus-macaroni.ts.net";
        };
        flake-qol = {
          enable = true;
          inputs = inputs // {settei = self;};
        };
        user = {
          enable = true;
          config = {
            home.packages = let
              extraPkgs = [inputs'.nh.packages.default];
            in
              [inputs'.settei.packages.base-packages] ++ extraPkgs;

            programs.git.enable = true;
            home.sessionVariables.EDITOR = "hx";
          };
        };
      };

      time.timeZone = lib.mkDefault "Europe/Warsaw";
    };
  in {
    nixos = name: module:
      inputs.nixpkgs.lib.nixosSystem {
        modules = [
          inputs.agenix.nixosModules.age
          inputs.disko.nixosModules.disko
          inputs.mailserver.nixosModules.default
          inputs.home-manager.nixosModules.home-manager
          inputs.hercules-ci-agent.nixosModules.agent-service
          # inputs.nvidia-patch.nixosModules.nvidia-patch
          self.nixosModules.settei
          self.nixosModules.common
          sharedOptions
          module
        ];
        specialArgs.configurationName = name;
      };

    darwin = name: module:
      inputs.darwin.lib.darwinSystem {
        modules = [
          inputs.agenix.darwinModules.age
          inputs.home-manager.darwinModules.home-manager
          inputs.hercules-ci-agent.darwinModules.agent-service
          self.darwinModules.settei
          self.darwinModules.common
          sharedOptions
          module
        ];
        specialArgs.configurationName = name;
      };
  };
}
