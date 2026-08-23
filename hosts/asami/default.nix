{
  config.systems.darwin.asami.module =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      nixpkgs.hostPlatform = "aarch64-darwin";

      ids.gids.nixbld = 350;

      settei.user.config = {
        settei.desktop.enable = true;
        home.packages = with pkgs; [
          anki-bin
        ];
      };
      settei.incus.enable = true;
      # TODO: Setup podman remote

      programs.mas = {
        enable = true;
        update = true;
        packages = {
          Bitwarden = 1352778147;
        };
      };

      system.defaults = {
        NSGlobalDomain.AppleInterfaceStyleSwitchesAutomatically = true;
        ".GlobalPreferences" = {
          "com.apple.mouse.scaling" = -1.0;
        };
        dock = {
          autohide = true;
          largesize = 64;
          minimize-to-application = true;
          orientation = "right";
          show-process-indicators = false;
          show-recents = false;
        };
        CustomUserPreferences.".GlobalPreferences" = {
          "com.apple.scrollwheel.scaling" = "-1";
        };
      };
      system.keyboard = {
        enableKeyMapping = true;
        remapCapsLockToEscape = true;
        nonUS.remapTilde = true;
        swapLeftCommandAndLeftAlt = true;
        swapRightCommandAndRightOption = true;
      };

      # Configuring keyboard, but only the builtin one.
      # hijiri uses ProductID instead, but on Tahoe the internal keyboard has VendorID=0 and ProductID=0.
      # Hopefully matching on the name won't be flaky.
      system.activationScripts.keyboard.text = lib.mkForce ''
        echo "configuring apple keyboard..." >&2
        hidutil property \
          --matching '{"Product":"Apple Internal Keyboard / Trackpad"}' \
          --set '{"UserKeyMapping":${builtins.toJSON config.system.keyboard.userKeyMapping}}' \
          > /dev/null
      '';
    };
}
