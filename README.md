<h1 align="center">
<ruby>
  雪定<rp>(</rp><rt>せってい</rt><rp>)</rp>
</ruby>
</h1>
Collection of my personal Nix configurations and opinionated NixOS, nix-darwin, home-manager, and flake-parts modules.

## Project structure
- hosts - per-machine configurations
  - kazuki - my linux arm server
  - legion - my linux x86 server
  - hijiri - my macbook[^1]
  - hijiri-vm - linux vm running on my macbook
  - miyagi - my work machine[^1]
  - ude - another linux arm server
  - kogata - my m1 mac mini doubling as a server
- modules - options which in principle should be reusable by others
  - */common - common options between my machines which aren't meant to be reusable by others
  - system
    - settei - my opinionated nixos/nix-darwin options
  - flake - flake-parts modules
- secrets - agenix secrets
- wrappers - nix packages wrapped with my configs (see: [wrapper-manager](https://github.com/viperML/wrapper-manager))
- assets - miscellaneous values reused throughout my config
- effects.nix - hercules-ci configuration

[^1]: Machine not migrated yet or in the process of migrating. See: https://nest.pijul.com/nrabulinski/nix-config

## Code guidelines

Not set rules but general guidelines for myself to hopefully keep this config clean, maintainable, and reusable.

- only importing downwards. this means no `imports = [ ../../foo/bar/some-module.nix ];`
- ideally only one level of imports.
this means i'll try to only do `imports = [ ./foo ];` or `imports = [ ./bar.nix ]` but not `imports = [ ./x/y/z.nix ];`
- the file should be roughly in order of most interesting to least interesting options.
- `imports` should be the first attribute (except for `_file`)
- anything that goes into `modules` should be usable by others, except for `modules/common`.
- there should be no implicit state anywhere in the config.
(sounds obvious but this is already broken with legion and the zfs pool but i'll let that one slide)
to achieve this i still need to create a proper live iso with my config and my bootstrapping ssh key

## TODOs
Sorted rougly by priority

- migrate the rest of my machines
- hercules-ci effects for deploying machines on update (if configuration is valid)
- go back to hercules or just migrate off of gha in some way
- fix disko
