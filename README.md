<h1 align="center">
<ruby>
  雪定<rp>(</rp><rt>せってい</rt><rp>)</rp>
</ruby>
</h1>

## Project structure
- hosts - per-machine configurations
  - common - common options between my machines which aren't reusable by others
  - kazuki - my linux arm server
  - legion - my linux x86 server[^1]
  - hijiri - my macbook[^1]
  - hijiri-vm - linux vm running on my macbook
  - miyagi - my work machine[^1]
- modules - options which in principle should be reusable by others
  - nixos
    - settei - my opinionated nixos options
  - flake - flake-parts modules
- secrets - agenix secrets
- wrappers - nix packages wrapped with my configs (see: [wrapper-manager](https://github.com/viperML/wrapper-manager))
- assets - miscellaneous values reused throughout my config
- effects.nix - hercules-ci configuration
- deploy.nix - deploy-rs configuration

[^1]: Machine not migrated yet or in the process of migrating. See: https://nest.pijul.com/nrabulinski/nix-config

## Code guidelines

Not set rules but general guidelines for myself to hopefully keep this config clean, maintainable, and reusable.

- only importing downwards. this means no `imports = [ ../../foo/bar/some-module.nix ];`
- ideally only one level of imports.
this means i'll try to only do `imports = [ ./foo ];` or `imports = [ ./bar.nix ]` but not `imports = [ ./x/y/z.nix ];`
- the file should be roughly in order of most interesting to least interesting options.
- `imports` should be the first attribute (except for `_file`)
- anything that goes into `modules` should be usable by others. any options specific to me go into `hosts/default.nix` or `hosts/common`.
- there should be no implicit state anywhere in the config.
(sounds obvious but this is already broken with legion and the zfs pool but i'll let that one slide)
to achieve this i still need to create a proper live iso with my config and my bootstrapping ssh key

## TODOs
Sorted rougly by priority

- finish migrating legion
- private nix cache
- set up hercules agent on legion
- hercules-ci checking if configuration is valid
- hercules-ci effects for deploying machines on update (if configuration is valid)
