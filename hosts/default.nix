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
    ./youko
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
          self.nixosModules.combined
          sharedOptions
        ];
        specialArgs.configurationName = "base";
      };

      baseDarwin = inputs.darwin.lib.darwinSystem {
        modules = [
          self.darwinModules.combined
          sharedOptions
        ];
        specialArgs.configurationName = "base";
      };
    in
    {
      nixos =
        name: module:
        baseNixos.extendModules {
          modules = [
            module
            config.__extraHostConfigs.${name} or { }
          ];
          specialArgs.configurationName = name;
        };

      darwin =
        name: module:
        let
          eval = baseDarwin._module.args.extendModules {
            modules = [
              module
              config.__extraHostConfigs.${name} or { }
            ];
            specialArgs.configurationName = name;
          };
        in
        eval
        // {
          system = eval.config.system.build.toplevel;
        };
    };
}
