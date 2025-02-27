# TODO: Proper desktop module
{
  config,
  pkgs,
  lib,
  username,
  ...
}:
{
  # Needed for nvidia and steam
  nixpkgs.config.allowUnfree = true;

  settei.user.config = {
    settei.desktop.enable = true;
    home.packages = with pkgs; [
      brightnessctl
      dmenu
    ];

    xsession.windowManager.i3 = {
      enable = true;
      config = {
        terminal = "wezterm";
        modifier = "Mod4";
      };
    };

    home.file.".xinitrc".source = pkgs.writeShellScript "xinitrc" ''
      xrandr --setprovideroutputsource modesetting NVIDIA-0
      xrandr --auto
      exec dbus-run-session i3
    '';
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession = { };
  };

  hardware.steam-hardware.enable = true;

  services.logind = lib.genAttrs [
    "lidSwitch"
    "lidSwitchDocked"
    "lidSwitchExternalPower"
  ] (_: "ignore");

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  programs.dconf.enable = true;
  services.dbus.enable = true;

  users.users.${username}.extraGroups = [
    "video"
    "input"
  ];

  # NVIDIA stuff
  services.xserver = {
    enable = true;
    excludePackages = [ pkgs.xterm ];
    videoDrivers = [ "nvidia" ];
    xkb.layout = "pl";
    displayManager.startx.enable = true;
    config = lib.mkForce ''
      Section "OutputClass"
        Identifier "intel"
        MatchDriver "i915"
        Driver "modesetting"
      EndSection

      Section "OutputClass"
        Identifier "nvidia"
        MatchDriver "nvidia-drm"
        Driver "nvidia"
        Option "AllowEmptyInitialConfiguration"
        Option "PrimaryGPU" "yes"
        ModulePath "${config.hardware.nvidia.package.bin}/lib/xorg/modules"
        ModulePath "${pkgs.xorg.xorgserver}/lib/xorg/modules"
      EndSection

      Section "InputClass"
        Identifier "touchpad"
        Driver "libinput"
        MatchIsTouchpad "on"
        Option "Tapping" "on"
        Option "TappingButtonMap" "lrm"
        Option "NaturalScrolling" "true"
      EndSection
    '';
    exportConfiguration = true;
  };
  services.libinput.enable = true;

  hardware.nvidia = {
    patch.enable = true;
    patch.nvidiaPackage = config.boot.kernelPackages.nvidia_x11_production;
    open = false;
    modesetting.enable = true;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}
