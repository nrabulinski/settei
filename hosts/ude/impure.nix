{ pkgs, ... }:
{
  services.nginx = {
    enable = true;
    recommendedProxySettings = false;
    recommendedGzipSettings = false;
    recommendedOptimisation = false;
    recommendedTlsSettings = false;
    appendHttpConfig = ''
      include /impure/nginx/*.conf;
    '';
  };
  networking.firewall.allowedTCPPorts = [ 80 ];

  users.users.impure-deploys = {
    isSystemUser = true;
    createHome = true;
    home = "/var/lib/impure";
    group = "impure-deploys";
    linger = true;
    shell = pkgs.bash;
  };
  users.groups.impure-deploys = { };
}
