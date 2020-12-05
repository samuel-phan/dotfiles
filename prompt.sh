function_exists() {
    FUNCTION_NAME=$1

    [ -z "$FUNCTION_NAME" ] && return 1

    declare -F "$FUNCTION_NAME" > /dev/null 2>&1
    return $?
}

set_title() {
    ORIG=$PS1
    TITLE="\[\e]0;$@\a\]"
    PS1=${ORIG}${TITLE}
}

bold=$(tput bold)
red=$(tput setaf 1)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
green=$(tput setaf 2)
reset=$(tput sgr0)
if [[ $EUID == 0 ]]; then
    issudo="$red"
else
    issudo="$green"
fi
prefix="\[$bold\]\d \t \[$issudo\]\u\[$reset\]@\[$bold$yellow\]\h \[$blue\]\w\[$reset\]"
suffix="\[$bold$issudo\]\\$\[$reset\]"
PS1="$prefix $suffix "

# git prompt config

# needed for "sudo su"
if ! function_exists __git_ps1; then
    . /etc/bash_completion.d/git-prompt
fi

export GIT_PS1_SHOWCOLORHINTS=1
export GIT_PS1_SHOWDIRTYSTATE=1 GIT_PS1_SHOWSTASHSTATE=1 GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM=verbose GIT_PS1_DESCRIBE_STYLE=branch

export PROMPT_COMMAND="__git_ps1 \"$prefix\" \" $suffix \"; set_title \"\u@\h: \w\""
