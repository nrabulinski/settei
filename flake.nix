{
  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      imports = [
        inputs.hercules-ci-effects.flakeModule

        ./assets
        ./hosts
        ./modules
        ./wrappers
        ./effects.nix
      ];

      perSystem = {
        inputs',
        pkgs,
        lib,
        ...
      }: {
        devShells.default = pkgs.mkShellNoCC {
          packages =
            [
              inputs'.agenix.packages.agenix
            ]
            # TODO: Contribute darwin support to nh
            ++ lib.optionals (!pkgs.stdenv.isDarwin) [inputs'.nh.packages.default];
        };

        formatter = pkgs.alejandra;
      };
    };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niko-nur = {
      url = "github:nrabulinski/nur-packages";
      # Not overriding nixpkgs to get cache hits
      # inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # agenix checks fail because of https://github.com/LnL7/nix-darwin/pull/687
    darwin-old-for-agenix.url = "github:lnl7/nix-darwin/22620845fee1cc16f4ea639509c50fd989ccc1ce";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "darwin-old-for-agenix";
      inputs.home-manager.follows = "home-manager";
    };
    mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wrapper-manager = {
      url = "github:viperML/wrapper-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wrapper-manager-hm-compat = {
      url = "github:nrabulinski/wrapper-manager-hm-compat";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    # stylix = {
    #   url = "github:danth/stylix";
    #   inputs = {
    #     nixpkgs.follows = "nixpkgs";
    #     home-manager.follows = "home-manager";
    #   };
    # };
    racket = {
      url = "github:nrabulinski/racket.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hercules-ci-agent = {
      url = "github:hercules-ci/hercules-ci-agent";
      inputs.flake-parts.follows = "flake-parts";
    };
    hercules-ci-effects = {
      url = "github:hercules-ci/hercules-ci-effects";
      inputs.flake-parts.follows = "flake-parts";
      inputs.hercules-ci-agent.follows = "hercules-ci-agent";
    };
    nh = {
      url = "github:viperML/nh";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://hyprland.cachix.org"
      "https://cache.garnix.io"
      "https://nix-community.cachix.org"
      "https://cache.nixos.org/"
      "https://hercules-ci.cachix.org"
      "https://nrabulinski.cachix.org"
    ];
    trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "hercules-ci.cachix.org-1:ZZeDl9Va+xe9j+KqdzoBZMFJHVQ42Uu/c/1/KMC5Lw0="
      "nrabulinski.cachix.org-1:Q5FD7+1c68uH74CQK66UWNzxhanZW8xcg1LFXxGK8ic="
    ];
  };
}
