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
PS1="\[$bold\]\d \t \[$issudo\]\u\[$reset\]@\[$bold$yellow\]\h \[$blue\]\w \[$issudo\]\\$\[$reset\] "
