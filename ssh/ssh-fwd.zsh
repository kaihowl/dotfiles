function ssh-fwd() {
  socket_name="/var/run/$RANDOM.gcm.socket" 
  remote_spec="$socket_name:$HOME/.gcm.socket"
  # Cannot pass in arbitrary env var, hack
  ssh -tA -R "$remote_spec" "$*" "GCM_SOCKET=$socket_name \$SHELL"
}
