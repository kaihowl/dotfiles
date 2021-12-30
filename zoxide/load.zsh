# Ensure that the jumped-to folder is echoed
export _ZO_ECHO=1

eval "$(zoxide init --cmd j zsh)"

# TODO(kaihowl) Depends on fzf completions internals
# Enable fzf completion on "j <prefix>**"
function _fzf_complete_j() {
  # shellcheck disable=SC2154
  zoxide query -i "${prefix}"
}
