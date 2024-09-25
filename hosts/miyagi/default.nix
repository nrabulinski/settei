{
  configurations.nixos.miyagi =
    {
      config,
      pkgs,
      username,
      ...
    }:
    {
      imports = [
        ./sway.nix
        ./disks.nix
      ];
      nixpkgs.hostPlatform = "x86_64-linux";

      boot.kernelModules = [
        "kvm-intel"
        "i2c-dev"
      ];

      boot = {
        loader.systemd-boot.enable = true;
        loader.efi.canTouchEfiVariables = true;
      };

      powerManagement.cpuFreqGovernor = "performance";

      networking.networkmanager.enable = true;

      zramSwap.enable = true;
      boot.kernel.sysctl."kernel.sysrq" = 1;

      age.secrets.niko-pass.file = ../../secrets/miyagi-niko-pass.age;
      users.users.${username} = {
        hashedPasswordFile = config.age.secrets.niko-pass.path;
        extraGroups = [
          "libvirtd"
          "i2c"
          "networkmanager"
        ];
      };

      settei.tailscale = {
        ipv4 = "100.103.204.32";
        ipv6 = "fd7a:115c:a1e0:ab12:4843:cd96:6267:cc20";
      };
      settei.user.config = {
        common.desktop.enable = true;
        home.packages = [ pkgs.slack ];
        programs.git.userEmail = "nrabulinski@antmicro.com";
        # TODO: Move to common?
        xdg.mimeApps = {
          enable = true;
          defaultApplications = {
            "x-scheme-handler/http" = "org.qutebrowser.qutebrowser.desktop";
            "x-scheme-handler/https" = "org.qutebrowser.qutebrowser.desktop";
            "x-scheme-handler/chrome" = "org.qutebrowser.qutebrowser.desktop";
            "text/html" = "org.qutebrowser.qutebrowser.desktop";
            "application/x-extension-htm" = "org.qutebrowser.qutebrowser.desktop";
            "application/x-extension-html" = "org.qutebrowser.qutebrowser.desktop";
            "application/x-extension-shtml" = "org.qutebrowser.qutebrowser.desktop";
            "application/xhtml+xml" = "org.qutebrowser.qutebrowser.desktop";
            "application/x-extension-xhtml" = "org.qutebrowser.qutebrowser.desktop";
            "application/x-extension-xht" = "org.qutebrowser.qutebrowser.desktop";
            "application/pdf" = "org.qutebrowser.qutebrowser.desktop";
          };
        };
      };
      common.incus.enable = true;
      virtualisation.podman.enable = true;

      services.udisks2.enable = true;
      services.printing = {
        enable = true;
        drivers = [ pkgs.brlaser ];
      };
      services.avahi = {
        enable = true;
        nssmdns4 = true;
      };
      hardware.bluetooth = {
        enable = true;
        settings.General.ControllerMode = "bredr";
      };
      hardware.keyboard.qmk.enable = true;

      systemd.coredump.enable = true;

      # Needed for enableAllFirmware
      nixpkgs.config.allowUnfree = true;
      hardware = {
        enableAllFirmware = true;
        cpu.intel.updateMicrocode = true;
      };
    };
}
