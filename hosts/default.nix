{
  config,
}:
let
  inputs = builtins.mapAttrs (_: input: input.result) config.inputs;
in
{
  includes = [
    ./kazuki
    ./hijiri-vm
    ./hijiri
    # TODO: Custom installer ISO
    # ./installer
    ./ude
    ./kogata
    ./youko
  ];

  config.configBuilders =
    let
      sharedOptions = {
        _file = ./default.nix;

        settei.sane-defaults.allSshKeys = config.assets.sshKeys.user;
        settei.flake-qol.inputs = inputs // {
          settei = inputs.self;
        };
      };

      baseNixos = inputs.nixpkgs.lib.nixosSystem {
        modules = [
          inputs.self.nixosModules.combined
          sharedOptions
        ];
        specialArgs.configurationName = "base";
      };

      baseDarwin = inputs.darwin.lib.darwinSystem {
        modules = [
          inputs.self.darwinModules.combined
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
            config.extraHostConfigs.${name} or { }
          ];
          specialArgs.configurationName = name;
        };

      darwin =
        name: module:
        let
          eval = baseDarwin._module.args.extendModules {
            modules = [
              module
              config.extraHostConfigs.${name} or { }
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
