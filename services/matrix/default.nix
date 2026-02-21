let
  # generate a list of numbers from start to end inclusive
  range = start: end: builtins.genList (x: x + start) (end - start + 1);
in
{
  config.services.matrix = {
    host = "kazuki";
    ports = [
      # continuwuity
      6168
      # turn/stun
      3478
      5349
      # livekit
      7880
      7881
      6169
    ]
    # media relay
    ++ (range 50201 65535)
    # livekit
    ++ (range 50100 50200);
    module =
      { config, ... }:
      {
        age.secrets.rab-lol-cf = {
          file = ../../secrets/rab-lol-cf.age;
          owner = config.services.nginx.user;
        };
        age.secrets.coturn-secret = {
          file = ../../secrets/coturn-secret.age;
          owner = "turnserver";
          group = "continuwuity";
          mode = "440";
        };

        imports = [
          ./continuwuity.nix
          ./coturn.nix
          ./proxy.nix
          ./livekit.nix
        ];

        networking.firewall.allowedTCPPorts = [
          80
          443
          8448
          # turn/stun
          3478
          5349
          # livekit
          7881
        ];
        networking.firewall.allowedUDPPorts = [
          # turn/stun
          3478
          5349
        ]
        # media relay
        ++ (range 50201 65535)
        # livekit
        ++ (range 50100 50200);

        security.acme.certs."rab.lol" = {
          email = "nikodem@rabulinski.com";
          dnsProvider = "cloudflare";
          credentialsFile = config.age.secrets.rab-lol-cf.path;
        };
        security.acme.certs."matrix.rab.lol" = {
          email = "nikodem@rabulinski.com";
          dnsProvider = "cloudflare";
          credentialsFile = config.age.secrets.rab-lol-cf.path;
        };
        security.acme.certs."turn.rab.lol" = {
          email = "nikodem@rabulinski.com";
          dnsProvider = "cloudflare";
          credentialsFile = config.age.secrets.rab-lol-cf.path;
          group = "turnserver";
        };
        security.acme.certs."livekit.rab.lol" = {
          email = "nikodem@rabulinski.com";
          dnsProvider = "cloudflare";
          credentialsFile = config.age.secrets.rab-lol-cf.path;
        };
      };
  };
}
