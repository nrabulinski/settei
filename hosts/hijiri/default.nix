{
  configurations.darwin.hijiri = {pkgs, ...}: {
    imports = [
      ./skhd.nix
      ./yabai.nix
    ];

    nixpkgs.system = "aarch64-darwin";

    settei.user.config = {
      common.desktop.enable = true;
      home.packages = with pkgs; [
        utm
        podman
        podman-compose
        qemu
        anki-bin
      ];
    };

    system.defaults = {
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
      # swap right command and right alt too
      userKeyMapping = [
        {
          HIDKeyboardModifierMappingSrc = 30064771302;
          HIDKeyboardModifierMappingDst = 30064771303;
        }
        {
          HIDKeyboardModifierMappingSrc = 30064771303;
          HIDKeyboardModifierMappingDst = 30064771302;
        }
      ];
    };
  };
}
