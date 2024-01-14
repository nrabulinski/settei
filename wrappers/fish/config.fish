# Set up path
fish_add_path --path --prepend '@bat@/bin'
fish_add_path --path --prepend '@eza@/bin'

# Abbreviations
abbr --add --global -- flake-update 'nix flake lock --update-input'
abbr --add --global -- ns 'nix shell'
abbr --add --global -- nss 'nix search'
abbr --add --global -- vim hx

# Aliases
alias cat bat
alias l 'eza -lah --group-directories-first --icons'
