# The rest of my fun git aliases
alias g="git"
alias glog="git log --graph --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
alias gl="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias ga='git add'
alias gf='git fetch'
alias gp='git push'
alias gpr='git pull --rebase'
alias gd='git diff'
alias gc='git commit'
alias gca='git commit -a'
alias gco='git checkout'
alias gcob='git checkout -B'
alias gcod='git checkout --detach'
alias gcb='git copy-branch-name'
alias gb='git branch'
alias gs='git status -sb' # upgrade your git if -sb breaks for you. it's fun.
alias gsmu='git submodule update --init'
alias gsms='git submodule sync'
alias grd='git review -d'
alias grf='git review -f'
alias gsl="git stash list --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'"
alias gsp="git-stash-push"
alias gstl='git stash list'
alias gsts='git stash show'
alias gsta="git stash push"
alias gstp="git stash pop"
alias gstaa="git stash --include-untracked"
alias gstaaa="git stash --all"
alias grm="git rm"
alias grbu="git rebase @{u}"
alias gru!="git reset --hard @{u} && gsmu"
alias gdt="git difftool"
alias gm="git merge"
alias gma="git merge --abort"
alias grbi="git rebase --interactive"
alias grbc="git rebase --continue"
alias grba="git rebase --abort"
alias gmb="git merge-base"
function delete_gone_local_branches() {
  git branch --format '%(refname:short) %(if) %(upstream) %(then) %(if) %(upstream:trackshort) %(then) KEEP %(else) [[[TRASH]]] %(end) %(else) KEEP %(end)' \
    | grep -F ' [[[TRASH]]] ' | awk '{print $1}' | xargs git branch -D
}
alias gbprune!="delete_gone_local_branches"
function git_rebase_interactive() {
  if [[ -n $1 ]]; then
    git rebase -i "$1"
  else
    git rebase -i "@{u}"
  fi
}
alias gri="git_rebase_interactive"
