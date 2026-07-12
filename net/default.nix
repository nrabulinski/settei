{ inputs }: {
  config.packages.home-router = {
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
    builder = "nixpkgs-flake";
    package =
      { pkgs }:
      let
        mikrotik = import inputs.mikrotik { inherit pkgs; };
        eval = mikrotik.mkRouter ./home/router.nix;
      in
      eval.config.build.activate;
  };
}
