{
  config,
  inputs,
}:
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

  config.systems.builders =
    let
      sharedOptions = {
        _file = ./default.nix;

        settei.sane-defaults.allSshKeys = config.assets.sshKeys.user;
        settei.flake-qol.inputs = inputs // {
          settei = inputs.self;
        };
      };
    in
    {
      nixos =
        name: module:
        inputs.nixpkgs.lib.nixosSystem {
          modules = [
            config.nixosModules.combined
            sharedOptions
            module
            config.extraHostConfigs.${name} or { }
          ];
          specialArgs.configurationName = name;
        };

      darwin =
        name: module:
        inputs.darwin.lib.darwinSystem {
          modules = [
            config.darwinModules.combined
            sharedOptions
            module
            config.extraHostConfigs.${name} or { }
          ];
          specialArgs.configurationName = name;
        };
    };
}
