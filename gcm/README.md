# git-credential-manager integration

To make use of the local git-credential-manager on a remote host, this module contains the necessary helpers.

## Design

We always use a `gcm-client` that connects over a unix domain socket to the 
`gcm-server`. The args[1] passed to the client is mapped to `args=args[1]` and
prepended to the stdin passed to the `gcm-client`.

The `gcm-server` undoes this and passes the commands to the git credential helper,
which in turn is the git-credential-manager.

To make this work remote, we forward the socket via ssh to the remote. As remote
socket files are not deleted, we clean then up on tmux exit iff we are connected
via ssh.


## Test plan

Test local interaction:
- `echo "" | gcm-client ping`
- `echo -e "protocol=https\nhost=github.com\n\n" | gcm-client get`

Setup remote ssh host:
- Connect with a single session
  - Test the same commands as for the local interaction.
- Disconnect
  - Check with the same commands above to verify that no stale socket files remained in place
  - Double check the `StreamLocalBindUnlink` option in sshd\_config
- Connect with two sessions:
  - Verify both work as above.
  - Verify that when disconnecting the first, the second remains functional.
