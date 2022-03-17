#!/bin/zsh

if ! tmux -D -c 'exit'; then
  echo "No support for supervised/non-daemonized tmux"
  echo "Skipping test"
  exit 0
fi

set -e

echo "Starting tmux background session"
tmux -D &
tmux_pid=$!

function kill_tmux {
  kill ${tmux_pid}
  wait ${tmux_pid}
}

trap kill_tmux EXIT

echo "Waiting for tmux to be started..."
while ! tmux list-sessions; do
  sleep 1
done

echo "Source tmux configuration to check for errors"
tmux source "$DOTS/tmux/tmux.conf.symlink"

echo "Success"
