let
  lock = builtins.fromJSON (builtins.readFile ./flake.lock);
  inherit (lock.nodes.__flake-compat.locked) narHash rev url;
  flake-compat = builtins.fetchTarball {
    url = "${url}/archive/${rev}.tar.gz";
    sha256 = narHash;
  };
  flake = import flake-compat {
    src = ./.;
    copySourceTreeToStore = false;
    useBuiltinsFetchTree = true;
  };
in
# Workaround for https://github.com/nilla-nix/nilla/issues/14
builtins.mapAttrs (_: input: input // { type = "derivation"; }) flake.inputs
