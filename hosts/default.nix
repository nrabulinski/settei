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
    ./miyagi
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

      baseNixos = inputs.nixpkgs.lib.nixosSystem {
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
        ];
        specialArgs.configurationName = "base";
      };

      baseDarwin = inputs.darwin.lib.darwinSystem {
        modules = [
          inputs.agenix.darwinModules.age
          inputs.home-manager.darwinModules.home-manager
          inputs.lix-module.nixosModules.default
          self.darwinModules.settei
          self.darwinModules.common
          sharedOptions
        ];
        specialArgs.configurationName = "base";
      };
    in
    {
      nixos =
        name: module:
        baseNixos.extendModules {
          modules = [ module ];
          specialArgs.configurationName = name;
        };

      darwin =
        name: module:
        let
          eval = baseDarwin._module.args.extendModules {
            modules = [ module ];
            specialArgs.configurationName = name;
          };
        in
        {
          system = eval.config.system.build.toplevel;
        };
    };
}
