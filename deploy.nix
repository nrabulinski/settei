{
  self,
  lib,
  inputs,
  ...
}: {
  flake.deploy.nodes =
    lib.mapAttrs (name: value: {
      hostname = name;
      sshUser = "niko";
      profiles.system = {
        user = "root";
        path = inputs.deploy-rs.lib.${value.pkgs.stdenv.system}.activate.nixos value;
      };
      remoteBuild = true;
    })
    self.nixosConfigurations;
}
