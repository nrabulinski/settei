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
    abbr --add --global -- gca 'git commit --amend --no-edit'
    abbr --add --global -- gch 'git checkout'
    abbr --add --global -- gss 'git switch'
    abbr --add --global -- ga 'git add'
    abbr --add --global -- gr 'git rebase'
    abbr --add --global -- gri 'git rebase -i --autosquash'
    abbr --add --global -- grc 'git rebase --continue'
    abbr --add --global -- gra 'git rebase --abort'
    abbr --add --global -- gd 'git diff'
    abbr --add --global -- gdd 'git diff --cached'
    abbr --add --global -- gl 'git log'
    abbr --add --global -- gf 'git fixup' # See pkgs/default.nix

    # Aliases
    alias cat bat
    alias l 'eza -lah --group-directories-first --icons'

    # Integrations
    zoxide init fish | source
    direnv hook fish | source
    function y --wraps yazi
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
            __zoxide_cd_internal -- "$cwd"
        end
        rm -f -- "$tmp"
    end
end
