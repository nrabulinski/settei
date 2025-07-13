{
  services.nginx = {
    enable = true;
    appendHttpConfig = ''
      include /impure/nginx/*.conf;
    '';
  };
  networking.firewall.allowedTCPPorts = [ 80 ];
}
