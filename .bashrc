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
        read "REPLY?Remove the branch \"$branch\"? (y/n) "
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Remove \"$branch\"..."
            git branch -d "$branch" || return $?
        else
            echo "Skipped."
        fi
    done
    echo '--- git branch -vv'
    git branch -vv
}
