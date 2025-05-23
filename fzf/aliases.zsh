# Source: https://github.com/junegunn/fzf/wiki/examples#git
# fbr - checkout git branch (including remote branches), sorted by most recent commit, limit 30 last branches
fbr() {
  local branches branch
  pattern="**/${1:-refs/heads}/**"
  branches=$(git for-each-ref --sort=-committerdate "${pattern}" --format="%(refname:short)") &&
  branch=$(echo "$branches" |
           fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
  git checkout "$(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")"
}

# Source: https://gist.github.com/junegunn/8b572b8d4b5eddd8b85e5f4d40f17236
# Minor change: Prepend "fzf-key-" to function names to avoid name collisions
# with git aliases
# ----------
is_in_git_repo() {
  git rev-parse HEAD > /dev/null 2>&1
}

fzf-down() {
  fzf --height 50% "$@" --border --no-sort
}

fzf-key-gf() {
  is_in_git_repo || return
  git -c color.status=always status --short |
  fzf-down -m --ansi --nth 2..,.. \
    --preview '(git diff --color=always -- {-1} | sed 1,4d; cat {-1}) | head -500' |
  cut -c4- | sed 's/.* -> //'
}

fzf-key-gb() {
  is_in_git_repo || return
  # shellcheck disable=SC2016
  git branch -a --sort=committerdate --color=always | grep -v '/HEAD\s' |
  fzf-down --ansi --multi --tac --preview-window right:70% \
    --preview 'git log --oneline --graph --date=short --color=always --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1) | head -'$LINES |
  sed 's/^..//' | cut -d' ' -f1 |
  sed 's#^remotes/##'
}

fzf-key-gt() {
  is_in_git_repo || return
  git tag --sort -version:refname |
  fzf-down --multi --preview-window right:70% \
    --preview 'git show --color=always {} | head -'$LINES
}

fzf-key-gh() {
  is_in_git_repo || return
  git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=always |
  fzf-down --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' \
    --header 'Press CTRL-S to toggle sort' \
    --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always | head -'$LINES |
  grep -o "[a-f0-9]\{7,\}"
}

fzf-key-gr() {
  is_in_git_repo || return
  git reflog --color=always "$@" |
  fzf-down --no-multi --ansi --no-sort \
    --preview 'git show --color=always {1}' |
  cut -d' ' -f1
}

fzf-key-gl() {
  is_in_git_repo || return
  git reflog --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --color=always |
  fzf-down --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' \
    --header 'Press CTRL-S to toggle sort' \
    --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always | head -'$LINES |
  grep -o "[a-f0-9]\{7,\}"
}

join-lines() {
  local item
  # shellcheck disable=SC2034
  while read -r item; do
    # shellcheck disable=SC2296
    echo -n "${(q)item} "
  done
}

bind-git-helper() {
  local c
  for c in "$@"; do
    eval "fzf-g$c-widget() { local result=\$(fzf-key-g$c | join-lines); zle reset-prompt; LBUFFER+=\$result }"
    eval "zle -N fzf-g$c-widget"
    eval "bindkey '^g^$c' fzf-g$c-widget"
  done
}
bind-git-helper f b t r h l s
unset -f bind-git-helper
# ----------

fzf-key-xo() {
  if [[ -z "$TMUX_PANE" ]]; then
    return
  fi
  tmux list-panes -F '#P' | xargs -n 1 tmux capture-pane -J -p -t | tr -s ' 	' '\n' | grep -v '^$' | awk '
  {
    if (data[$0]++ == 0)
      lines[++count] = $0
  }

  END {
  for (i = 1; i <= count; i++)
    print lines[i]
  }' | tac | fzf-down
}

fzf-xo-widget() {
  local result;
  result=$(fzf-key-xo)
  zle reset-prompt
  LBUFFER+=$result
}

zle -N fzf-xo-widget
bindkey '^x^o' fzf-xo-widget

# Bind ctrl-p same as ctrl-r
bindkey -M emacs '^P' fzf-history-widget
bindkey -M vicmd '^P' fzf-history-widget
bindkey -M viins '^P' fzf-history-widget
