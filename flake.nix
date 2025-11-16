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
      url = "github:viperML/wrapper-manager";
      flake = false;
    };
    wrapper-manager-hm-compat = {
      url = "github:nrabulinski/wrapper-manager-hm-compat";
      flake = false;
    };
    racket = {
      url = "github:nrabulinski/racket.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    conduit-src = {
      url = "gitlab:famedly/conduit?ref=next";
      flake = false;
    };
    attic = {
      url = "https://git.lix.systems/nrabulinski/attic/archive/main.tar.gz";
      flake = false;
    };
    crane = {
      url = "github:ipetkov/crane";
      flake = false;
    };
    helix = {
      url = "github:helix-editor/helix";
      flake = false;
    };
    zjstatus = {
      url = "github:dj95/zjstatus";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lix = {
      url = "https://git.lix.systems/lix-project/lix/archive/main.tar.gz";
      flake = false;
    };
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/main.tar.gz";
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
    nh = {
      url = "github:nix-community/nh";
      flake = false;
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      flake = false;
    };
  };
}
