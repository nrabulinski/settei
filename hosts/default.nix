{
  config,
  self,
  inputs,
  ...
}:
{
  imports = [
    ./kazuki
    ./hijiri-vm
    ./hijiri
    ./legion
    # TODO: Custom installer ISO
    # ./installer
    ./ude
    ./kogata
  ];

  builders =
    let
      sharedOptions = {
        _file = ./default.nix;

        settei.sane-defaults.allSshKeys = config.assets.sshKeys.user;
        settei.flake-qol.inputs = inputs // {
          settei = self;
        };
      };
    in
    {
      nixos =
        name: module:
        inputs.nixpkgs.lib.nixosSystem {
          modules = [
            inputs.agenix.nixosModules.age
            inputs.disko.nixosModules.disko
            inputs.mailserver.nixosModules.default
            inputs.home-manager.nixosModules.home-manager
            inputs.nvidia-patch.nixosModules.nvidia-patch
            inputs.attic.nixosModules.atticd
            inputs.lix-module.nixosModules.default
            self.nixosModules.settei
            self.nixosModules.common
            sharedOptions
            module
          ];
          specialArgs.configurationName = name;
        };

      darwin =
        name: module:
        inputs.darwin.lib.darwinSystem {
          modules = [
            inputs.agenix.darwinModules.age
            inputs.home-manager.darwinModules.home-manager
            self.darwinModules.settei
            self.darwinModules.common
            sharedOptions
            module
          ];
          specialArgs.configurationName = name;
        };
    };
}
