function git_current_branch
    git rev-parse --abbrev-ref HEAD 2>/dev/null
end

function git_main_branch
    # bail out if we're not in a git repo
    command git rev-parse --git-dir >/dev/null 2>/dev/null; or return

    for ref in refs/{heads,remotes/{origin,upstream}}/{main,trunk,mainline,default,stable,master}
        if command git show-ref -q --verify $ref
            echo (basename $ref)
            return 0
        end
    end

    echo master
    return 1
end

