{
  configurations.darwin.kogata =
    { pkgs, lib, ... }:
    {
      nixpkgs.system = "aarch64-darwin";

      settei.user.config.common.desktop.enable = true;

      # TODO: Make it a settei module so it's easy to concatenate which pkgs are allowed
      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "teams" ];
      environment.systemPackages = with pkgs; [ teams ];

      common.hercules.enable = true;
      common.github-runner = {
        enable = true;
        runners.settei.url = "https://github.com/nrabulinski/settei";
      };
    };
}
