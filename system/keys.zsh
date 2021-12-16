# Pipe my public key to my clipboard.
# shellcheck shell=bash
alias pubkey="more ~/.ssh/id_rsa.pub | pbcopy | echo '=> Public key copied to pasteboard.'"
