{
  defaultEffectSystem = "aarch64-linux";

  hercules-ci = {
    flake-update = {
      enable = true;
      when.dayOfWeek = "Mon";
    };
  };
}
