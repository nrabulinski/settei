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

    packages.git-commit-last = pkgs.writeShellApplication {
      name = "git-commit-last";
      text = ''
        GITDIR="$(git rev-parse --git-dir)"
        git commit -eF "$GITDIR/COMMIT_EDITMSG"
      '';
    };
  };
}
