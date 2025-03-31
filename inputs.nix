let
  lock = builtins.fromJSON (builtins.readFile ./flake.lock);
  nodeName = lock.nodes.root.inputs.__flake-compat;
  inherit (lock.nodes.${nodeName}.locked) narHash rev url;
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
