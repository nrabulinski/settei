{perInput}: {
  lib,
  config,
  ...
}: {
  _file = ./default.nix;

  imports = [
    ./sane-defaults.nix
    (import ./flake-qol.nix {inherit perInput;})
    ./user.nix
  ];

  options.settei = with lib; {
    username = mkOption {
      type = types.str;
    };
  };
}
