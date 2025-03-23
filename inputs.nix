let
  lock = builtins.fromJSON (builtins.readFile ./flake.lock);
  nodeName = lock.nodes.root.inputs.__flake-compat;
  inherit (lock.nodes.${nodeName}.locked) narHash rev url;
  flake-compat = builtins.fetchTarball {
    url = "${url}/archive/${rev}.tar.gz";
    sha256 = narHash;
  };
  flake = import flake-compat { src = ./.; };
in
flake.inputs
