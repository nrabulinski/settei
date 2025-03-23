{ config }:
let
  systems = [
    "x86_64-linux"
    "aarch64-linux"
    "aarch64-darwin"
  ];
  builder = "nixpkgs-flake";
  mkPackage = package: {
    inherit systems package builder;
  };

in
{
  config.packages.conduit-next = {
    inherit systems builder;
    package = import ./conduit;
    settings.args = {
      src = config.inputs.conduit-src.result;
      crane = config.inputs.crane.result.mkLib;
      fenix = config.inputs.fenix.result.packages;
    };
  };

  config.packages.git-commit-last = mkPackage (
    { writeShellApplication }:
    writeShellApplication {
      name = "git-commit-last";
      text = ''
        GITDIR="$(git rev-parse --git-dir)"
        git commit -eF "$GITDIR/COMMIT_EDITMSG"
      '';
    }
  );

  config.packages.git-fixup = mkPackage (
    {
      lib,
      writeShellApplication,
      fzf,
    }:
    writeShellApplication {
      name = "git-fixup";
      text = ''
        git log -n 50 --pretty=format:'%h %s' --no-merges | \
        ${lib.getExe fzf} | \
        cut -c -7 | \
        xargs -o git commit --fixup
      '';
    }
  );
}
