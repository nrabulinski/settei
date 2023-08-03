{
  config,
  self,
  inputs,
  lib,
  ...
}: {
  mappers = {
    nixos = module: {
      modules = [
        inputs.agenix.nixosModules.age
        inputs.disko.nixosModules.disko
        inputs.mailserver.nixosModules.default
        self.nixosModules.settei
        {
          settei = {
            username = "niko";
            sane-defaults.enable = true;
            flake-qol = {
              enable = true;
              inherit inputs;
            };
          };
        }
        module
      ];
    };
  };

  imports = [
    ./kazuki
    ./hijiri-vm
  ];
}
