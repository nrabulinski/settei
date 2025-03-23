{
  outputs =
    inputs@{ flake-parts, ... }:
    let
      nilla = import ./nilla.nix { inherit inputs; };
      transpose =
        attrs:
        let
          inherit (inputs.nixpkgs) lib;
          # maps an attrset of systems to packages to list of [ {name; system; value;} ]
          pkgToListAll =
            name: pkg:
            map (system: {
              inherit name system;
              value = pkg.${system};
            }) (builtins.attrNames pkg);
          pkgsToListAll = pkgs: map (name: pkgToListAll name pkgs.${name}) (builtins.attrNames pkgs);
          # list of all packages in format [ {name; system; value;} ]
          allPkgs = lib.flatten (pkgsToListAll attrs);
          systems = builtins.groupBy (pkg: pkg.system) allPkgs;
        in
        builtins.mapAttrs (_: pkgs: lib.listToAttrs pkgs) systems;
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      imports = [
        inputs.treefmt.flakeModule

        ./assets
        ./hosts
        ./modules
        ./wrappers
        ./services
      ];

      flake.devShells = transpose (builtins.mapAttrs (_: shell: shell.result) nilla.shells);
      flake.packages = transpose (builtins.mapAttrs (_: pkg: pkg.result) nilla.packages);

      perSystem = {
        treefmt = {
          programs.deadnix.enable = true;
          programs.nixfmt.enable = true;
          programs.statix.enable = true;
          programs.fish_indent.enable = true;
          programs.deno.enable = true;
          programs.stylua.enable = true;
          programs.shfmt.enable = true;
          settings.global.excludes = [
            # agenix
            "*.age"

            # racket
            "*.rkt"
            "**/rashrc"

            # custom assets
            "*.png"
            "*.svg"
          ];
          settings.on-unmatched = "fatal";
        };
      };
    };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
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
    darwin = {
      # TODO: Move back once https://github.com/LnL7/nix-darwin/issues/1392 is resolved
      # url = "github:lnl7/nix-darwin";
      url = "github:lnl7/nix-darwin?ref=refs/pull/1335/merge";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "darwin";
      inputs.home-manager.follows = "home-manager";
    };
    mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wrapper-manager = {
      # TODO: Move back once https://github.com/viperML/wrapper-manager/issues/14 is resolved
      # url = "github:viperML/wrapper-manager";
      url = "github:nrabulinski/wrapper-manager?ref=wrap-certain-programs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wrapper-manager-hm-compat = {
      url = "github:nrabulinski/wrapper-manager-hm-compat";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
      inputs.wrapper-manager.follows = "wrapper-manager";
    };
    racket = {
      url = "github:nrabulinski/racket.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    conduit-src = {
      url = "gitlab:famedly/conduit?ref=next";
      flake = false;
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    crane = {
      url = "github:ipetkov/crane";
    };
    firefox-darwin = {
      url = "github:bandithedoge/nixpkgs-firefox-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niko-nur = {
      url = "github:nrabulinski/nur-packages";
    };
    attic = {
      url = "git+https://git.lix.systems/nrabulinski/attic.git";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.crane.follows = "crane";
      inputs.lix.follows = "lix";
      inputs.lix-module.follows = "lix-module";
    };
    helix = {
      url = "github:helix-editor/helix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zjstatus = {
      url = "github:dj95/zjstatus";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.crane.follows = "crane";
    };
    lix = {
      url = "git+https://git.lix.systems/lix-project/lix.git";
      flake = false;
    };
    lix-module = {
      url = "git+https://git.lix.systems/lix-project/nixos-module.git";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.lix.follows = "lix";
    };
    treefmt = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    __flake-compat = {
      url = "git+https://git.lix.systems/lix-project/flake-compat.git";
      flake = false;
    };
    nilla = {
      url = "github:nilla-nix/nilla";
      flake = false;
    };
  };

  /*
    TODO: Uncomment once (if ever?) nixConfig makes sense in flakes
    nixConfig = {
      extra-substituters = [
        "https://hyprland.cachix.org"
        "https://cache.garnix.io"
        "https://nix-community.cachix.org"
        "https://hercules-ci.cachix.org"
        "https://nrabulinski.cachix.org"
        "https://cache.nrab.lol"
      ];
      extra-trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "hercules-ci.cachix.org-1:ZZeDl9Va+xe9j+KqdzoBZMFJHVQ42Uu/c/1/KMC5Lw0="
        "nrabulinski.cachix.org-1:Q5FD7+1c68uH74CQK66UWNzxhanZW8xcg1LFXxGK8ic="
        "cache.nrab.lol-1:CJl1TouOyuJ1Xh4tZSXLwm3Upt06HzUNZmeyuEB9EZg="
      ];
    };
  */
}
