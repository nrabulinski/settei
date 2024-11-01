{ inputs, ... }:
{
  perSystem =
    { pkgs, lib, inputs', ... }:
    {
      packages.conduit-next = pkgs.callPackage ./conduit {
        src = inputs.conduit-src;
        crane = inputs.crane.mkLib pkgs;
        fenix = inputs'.fenix.packages;
      };

      packages.git-commit-last = pkgs.writeShellApplication {
        name = "git-commit-last";
        text = ''
          GITDIR="$(git rev-parse --git-dir)"
          git commit -eF "$GITDIR/COMMIT_EDITMSG"
        '';
      };

      packages.git-fixup = pkgs.writeShellApplication {
        name = "git-fixup";
        text = ''
          git log -n 50 --pretty=format:'%h %s' --no-merges | \
          ${lib.getExe pkgs.fzf} | \
          cut -c -7 | \
          xargs -o git commit --fixup
        '';
      };
    };
}
