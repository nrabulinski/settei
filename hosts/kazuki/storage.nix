{
  config,
  pkgs,
  ...
}: {
  age.secrets = {
    storage-box-creds.file = ../../secrets/storage-box-creds.age;
  };

  environment.systemPackages = with pkgs; [cifs-utils];
  fileSystems."/storage-box" = {
    fsType = "cifs";
    device = "//u389358.your-storagebox.de/backup";
    options = [
      "iocharset=utf8"
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=60"
      "x-systemd.device-timeout=5s"
      "x-systemd.mount-timeout=5s"
      "credentials=${config.age.secrets.storage-box-creds.path}"
    ];
  };

  networking.firewall.extraCommands = ''
    iptables -t raw -A OUTPUT -p udp -m udp --dport 137 -j CT --helper netbios-ns
  '';
}
