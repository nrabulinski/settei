status --is-interactive
and begin

    # Abbreviations
    ## nix
    abbr --add --global -- ns 'nix shell'
    abbr --add --global -- nss 'nix search'
    abbr --add --global -- flake-update 'nix flake lock --update-input'
    ## git
    abbr --add --global -- gs 'git status'
    abbr --add --global -- gp 'git pull'
    abbr --add --global -- gc 'git checkout'
    abbr --add --global -- ga 'git add'
    abbr --add --global -- gr 'git rebase'
    abbr --add --global -- gd 'git diff'
    abbr --add --global -- gl 'git log'

    # Aliases
    alias cat bat
    alias l 'eza -lah --group-directories-first --icons'

    zoxide init fish | source
    direnv hook fish | source

end
