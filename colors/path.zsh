# shellcheck disable=SC2206
fpath=($DOTS/colors $fpath)
export PATH=$DOTS/colors:$PATH

alias dark="change-color -b dark"
alias light="change-color -b light"
