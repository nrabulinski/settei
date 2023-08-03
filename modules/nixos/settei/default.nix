{perInput}: {
  lib,
  config,
  ...
}: {
  imports = [
    ./sane-defaults.nix
    (import ./flake-qol.nix {inherit perInput;})
  ];

  options.settei = with lib; {
    username = mkOption {
      type = types.str;
    };
  };
}
