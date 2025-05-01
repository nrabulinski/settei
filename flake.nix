{
  outputs = inputs: (import ./nilla.nix { inherit inputs; }).flake;

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
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
      inputs.lix.follows = "lix";
      inputs.lix-module.follows = "lix-module";
    };
    crane = {
      url = "github:ipetkov/crane";
      flake = false;
    };
    helix = {
      url = "github:helix-editor/helix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zjstatus = {
      url = "github:dj95/zjstatus";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.crane.follows = "attic/crane";
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
}
