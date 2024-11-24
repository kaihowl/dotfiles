function ssh-fwd() {
  echo $RANDOM > /dev/null
  socket_name="/tmp/$RANDOM.gcm.socket" 
  remote_spec="$socket_name:$HOME/.gcm.socket"
  # Cannot pass in arbitrary env var, hack
  ssh -tA -o ExitOnForwardFailure=yes -R "$remote_spec" "$*" "GCM_SOCKET=$socket_name \$SHELL -il"
}
