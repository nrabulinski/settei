{
  configurations.darwin.hijiri =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      imports = [
        ./skhd.nix
        ./yabai.nix
      ];

      nixpkgs.system = "aarch64-darwin";

      settei.user.config = {
        common.desktop.enable = true;
        home.packages = with pkgs; [
          utm
          qemu
          anki-bin
        ];
        programs.alacritty.settings.font.size = 14;
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

      system.activationScripts.keyboard.text = lib.mkForce ''
        # Configuring keyboard, but only the builtin one
        echo "configuring apple keyboard..." >&2
        hidutil property --matching '{"ProductID":0x0342}' --set '{"UserKeyMapping":${builtins.toJSON config.system.keyboard.userKeyMapping}}' > /dev/null
      '';
    };
}
