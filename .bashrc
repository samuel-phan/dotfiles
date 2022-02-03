function sjoin { local IFS="$1"; shift; echo "$*"; }

alias tree='tree --charset unicode'

export PYTHONSTARTUP=~/.pyrc

# git
git-clean-branches() {
    local main_branch
    (git branch | grep -q 'main$') && main_branch=main || main_branch=master
    echo '--- git branch -vv'
    git branch -vv
    echo "--- git checkout ${main_branch}"
    git checkout "${main_branch}" || return $?
    echo '--- git pull --rebase'
    git pull --rebase || return $?
    echo '--- git fetch -p'
    git fetch -p || return $?
    echo '--- git branch -vv'
    git branch -vv
    echo '--- scan gone branches to remove'
    for branch in $(git branch -vv | grep ': gone]' | awk '{print $1}'); do
        read "REPLY?Remove the branch \"$branch\"? (y/n) "
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Remove \"$branch\"..."
            if ! git branch -d "$branch"; then
                read "REPLY?Force remove the branch \"$branch\"? (y/n) "
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    echo "Force remove \"$branch\"..."
                    git branch -D "$branch"
                fi
            fi
        else
            echo "Skipped."
        fi
    done
    echo '--- git branch -vv'
    git branch -vv
}
