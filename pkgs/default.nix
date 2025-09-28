{
  lib,
  inputs,
}:
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
  atticPkgs = lib.attrs.generate systems (
    system:
    let
      pkgs = inputs.nixpkgs.legacyPackages.${system}.extend inputs.lix-module.overlays.default;
      craneLib = import inputs.crane { inherit pkgs; };
    in
    pkgs.callPackage "${inputs.attic}/crane.nix" { inherit craneLib; }
  );
in
{
  config.packages.conduit-next = {
    inherit systems builder;
    package = import ./conduit;
    settings.args = {
      src = inputs.conduit-src;
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

  config.packages.attic-client = {
    inherit systems;
    builder = "custom-load";
    package = { system }: atticPkgs.${system}.attic-client;
  };
  config.packages.attic-server = {
    inherit systems;
    builder = "custom-load";
    package = { system }: atticPkgs.${system}.attic-server;
  };

  config.packages.nh = {
    inherit systems builder;
    package = import "${inputs.nh}/package.nix";
    settings.args.rev = inputs.nh.shortRev;
  };
}
