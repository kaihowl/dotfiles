# shellcheck disable=all

export LS_COLORS="di=1;36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
# shellcheck disable=SC2154
zstyle ':completion:*:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu yes select

# shift-tab reverse menu completion
# shellcheck disable=SC2154
if [[ -n "${terminfo[kcbt]}" ]]; then
  bindkey '\t' menu-select "$terminfo[kcbt]" menu-select
  bindkey -M menuselect '\t' menu-complete "$terminfo[kcbt]" reverse-menu-complete
fi

# Consider e.g. slashes to be word boundaries
autoload -U select-word-style
select-word-style bash

