<h1 align="center">
<ruby>
  雪定<rp>(</rp><rt>せってい</rt><rp>)</rp>
</ruby>
</h1>
Collection of my personal Nix configurations and opinionated NixOS, nix-darwin, home-manager, and flake-parts modules.

> [!CAUTION]
> I tried to make the modules in this repository useful to others without having
> to modify them, meaning I tried to have many configuration options, have them
> be disabled by default, etc. That is no more and although I still encourage
> people to use my config for learning and inspiration, the modules will now
> assume they're running in my infrastructure and I'll only add configuration
> and/or enabling options when it makes sense to me, personally.

## Project structure

- hosts - per-machine configurations
  - kazuki - my linux arm server
  - legion - my linux x86 server
  - hijiri - my macbook
  - hijiri-vm - linux vm running on my macbook
  - ude - another linux arm server
  - kogata - my m1 mac mini doubling as a server
  - youko - my linux x86 server
- modules - options which in principle should be reusable by others
  - system - my opinionated nixos/nix-darwin modules
  - home - my opinionated home-manager modules
  - flake - flake-parts modules
- services - configs for services I self-host
- secrets - agenix secrets
- wrappers - nix packages wrapped with my configs (see:
  [wrapper-manager](https://github.com/viperML/wrapper-manager))
- assets - miscellaneous values reused throughout my config
- effects.nix - hercules-ci configuration

## Code guidelines

Not set rules but general guidelines for myself to hopefully keep this config
clean, maintainable, and reusable.

- only importing downwards. this means no
  `imports = [ ../../foo/bar/some-module.nix ];`
- ideally only one level of imports. this means i'll try to only do
  `imports = [ ./foo ];` or `imports = [ ./bar.nix ]` but not
  `imports = [ ./x/y/z.nix ];`
- the file should be roughly in order of most interesting to least interesting
  options.
- `imports` should be the first attribute (except for `_file`)
- there should be no implicit state anywhere in the config. (sounds obvious but
  this is already broken with legion and the zfs pool but i'll let that one
  slide) to achieve this i still need to create a proper live iso with my config
  and my bootstrapping ssh key

## TODOs

Sorted rougly by priority

- bring back ci (sorta done)
- hercules-ci effects for deploying machines on update (if configuration is
  valid)
- fix disko
- make the configuration truly declarative (to a reasonable degree)
- themeing solution
