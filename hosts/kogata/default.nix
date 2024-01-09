{
  configurations.darwin.kogata = {pkgs, ...}: {
    nixpkgs.system = "aarch64-darwin";

    settei.user.config = {
      home.packages = with pkgs; [alacritty];
    };

    common.hercules.enable = true;
  };
}
