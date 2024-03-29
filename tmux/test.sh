#!/bin/bash

set -e

echo "Starting tmux background session"
tmux -D &
tmux_pid=$!

function kill_tmux {
  kill ${tmux_pid} || true
  wait ${tmux_pid} || true
}

trap kill_tmux EXIT

echo "Waiting for tmux to be started..."
while ! tmux list-sessions > /dev/null 2>&1 ; do
  if ! ps -p $tmux_pid; then
    echo "No support for supervised/non-daemonized tmux"
    echo "Skipping test"
    exit 0
  fi
  sleep 1
done

echo "Source tmux configuration to check for errors"
tmux source "$DOTS/tmux/tmux.conf.symlink"

echo "Success"
