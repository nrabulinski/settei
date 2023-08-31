{
  config,
  self,
  inputs,
  lib,
  ...
}: {
  builders = {
    nixos = name: module: let
      combinedInputs = inputs // {settei = self;};
      baseOptions = {
        settei.flake-qol = {
          enable = true;
          inputs = combinedInputs;
        };
      };
      base = inputs.nixpkgs.lib.nixosSystem {
        modules = [
          inputs.agenix.nixosModules.age
          inputs.disko.nixosModules.disko
          inputs.mailserver.nixosModules.default
          self.nixosModules.settei
          baseOptions
        ];
      };
      defaultOptions = {
        username,
        inputs',
        lib,
        ...
      }: {
        settei = {
          username = lib.mkDefault "niko";
          sane-defaults.enable = lib.mkDefault true;
        };

        users.users.${username}.packages = lib.attrValues inputs'.settei.packages;
      };
    in
      base.extendModules {
        modules = [
          defaultOptions
          module
        ];
        specialArgs = {
          prev = base;
          configurationName = name;
        };
      };
  };

  imports = [
    ./kazuki
    ./hijiri-vm
  ];
}
