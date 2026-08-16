{ lib, ... }: {
  services.ncro = {
    enable = true;
    settings.server = {
      listen = ":6767";
    };
    settings.upstreams = [
      {
        url = "https://cache.nixos.org";
        priority = 10;
        public_key = "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=";
      }
      {
        url = "https://cache.rab.lol";
        priority = 20;
        public_key = "cache.rab.lol-1:/b0gE755WZeAHXxdtehRWroV4Vu6KOjjuoRLV24Sh4A=";
      }
      {
        url = "https://nix-community.cachix.org";
        priority = 30;
        public_key = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
      }
    ];
  };

  nix.settings.substituters = lib.mkForce [ "http://localhost:6767" ];
}
