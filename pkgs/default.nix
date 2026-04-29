{
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
  cellerFn =
    { pkgs, callPackage }:
    let
      craneLib = import inputs.crane { inherit pkgs; };
      eval = callPackage "${inputs.celler}/crane.nix" { inherit craneLib; };
    in
    eval.celler;
in
{
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

  config.packages.celler = mkPackage cellerFn;

  config.packages.nh = {
    inherit systems builder;
    package = import "${inputs.nh}/package.nix";
    settings.args.rev = inputs.nh.shortRev;
  };

  config.packages.zjstatus = {
    inherit systems builder;
    package = import ./zjstatus;
    settings.args = {
      src = inputs.zjstatus;
      inherit (inputs) rust-overlay;
    };
  };

  config.packages.ddns = mkPackage (import ./ddns/package.nix);

  config.packages.jetkvm-atx = mkPackage (import ./jetkvm-atx/package.nix);
}
