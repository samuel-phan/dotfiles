function sjoin { local IFS="$1"; shift; echo "$*"; }

alias tree='tree --charset unicode'

export PYTHONSTARTUP=~/.pyrc

# git
git-clean-branches() {
    echo '--- git branch -vv'
    git branch -vv
    echo '--- git checkout master'
    git checkout master || return $?
    echo '--- git pull --rebase'
    git pull --rebase || return $?
    echo '--- git fetch -p'
    git fetch -p || return $?
    echo '--- git branch -vv'
    git branch -vv
    echo '--- scan gone branches to remove'
    for branch in $(git branch -vv | grep ': gone]' | awk '{print $1}'); do
        read -p "Remove the branch \"$branch\"? (y/n) " REPLY
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Remove \"$branch\"..."
            if ! git branch -d "$branch"; then
                read -p "Force remove the branch \"$branch\"? (y/n) " REPLY
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    echo "Force remove \"$branch\"..."
                    git branch -D "$branch" || return $?
                fi
            fi
        else
            echo "Skipped."
        fi
    done
    echo '--- git branch -vv'
    git branch -vv
}
