{perInput}: {
  imports = [
    (import ../../shared/settei {inherit perInput;})
    ./sane-defaults.nix
  ];
}
