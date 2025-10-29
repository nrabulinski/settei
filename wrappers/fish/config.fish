status --is-interactive
and begin
    fish_vi_key_bindings insert

    # Abbreviations
    ## nix
    abbr --add -- ns 'nix shell'
    abbr --add -- nss 'nix search'
    abbr --add -- nfu 'nix flake update'
    ## git
    abbr --add -- gs 'git status'
    abbr --add -- gp 'git pull'
    abbr --add -- gps 'git push'
    abbr --add -- gc 'git commit'
    abbr --add -- gca 'git commit --amend --no-edit'
    abbr --add -- gch 'git checkout'
    abbr --add -- gss 'git switch'
    abbr --add -- ga 'git add'
    abbr --add -- gr 'git rebase'
    abbr --add -- gri 'git rebase -i --autosquash'
    abbr --add -- grc 'git rebase --continue'
    abbr --add -- gra 'git rebase --abort'
    abbr --add -- gd 'git diff'
    abbr --add -- gdd 'git diff --cached'
    abbr --add -- gl 'git log'
    abbr --add -- gf 'git fixup' # See pkgs/default.nix
    abbr --add --set-cursor -- gpss 'git push origin% "@:refs/for/main/$(git rev-parse --abbrev-ref @)" -o force-push=true'
    ## other
    abbr --add -- which 'command -v'

    # Aliases
    alias cat bat
    alias l 'eza -lah --group-directories-first --icons'

    # Integrations
    starship init fish | source
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
