status --is-interactive
and begin
    fish_vi_key_bindings insert

    # Abbreviations
    ## nix
    abbr --add --global -- ns 'nix shell'
    abbr --add --global -- nss 'nix search'
    abbr --add --global -- nfu 'nix flake update'
    ## git
    abbr --add --global -- gs 'git status'
    abbr --add --global -- gp 'git pull'
    abbr --add --global -- gps 'git push'
    abbr --add --global -- gc 'git commit'
    abbr --add --global -- gch 'git checkout'
    abbr --add --global -- ga 'git add'
    abbr --add --global -- gr 'git rebase'
    abbr --add --global -- gd 'git diff'
    abbr --add --global -- gl 'git log'

    # Aliases
    alias cat bat
    alias l 'eza -lah --group-directories-first --icons'

    # Integrations
    zoxide init fish | source
    direnv hook fish | source
    function y
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
            __zoxide_cd_internal -- "$cwd"
        end
        rm -f -- "$tmp"
    end
end
