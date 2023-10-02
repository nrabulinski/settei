{
  imports = [
    ./hercules.nix
  ];

  config = {
    system.stateVersion = "22.05";

    # https://github.com/NixOS/nixpkgs/issues/254807
    boot.swraid.enable = false;
  };
}
