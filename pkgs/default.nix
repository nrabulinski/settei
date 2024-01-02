{inputs, ...}: {
  perSystem = {
    pkgs,
    system,
    inputs',
    ...
  }: {
    packages.conduit-next = pkgs.callPackage ./conduit {
      src = inputs.conduit-src;
      crane = inputs.crane.lib.${system};
      fenix = inputs'.fenix.packages;
    };
  };
}
