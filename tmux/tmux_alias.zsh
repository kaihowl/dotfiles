# Add an alias to open a session if exists or create it

alias ta='tmux attach -t'
alias ts='tmux new-session -s'
alias tl='tmux list-sessions'

function to() {
  ta "$1" || ts "$1"
}
