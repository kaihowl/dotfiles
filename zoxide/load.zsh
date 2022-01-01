# Ensure that the jumped-to folder is echoed
export _ZO_ECHO=1

eval "$(zoxide init --cmd j zsh)"

# TODO(kaihowl) Depends on fzf completions internals
# Enable fzf completion on "j <prefix>**"
function _fzf_complete_j() {
  local result
  # shellcheck disable=SC2154
  result=$(zoxide query -i "${prefix}")
  # Delete both "j" and "<prefix>**"
  zle backward-delete-word
  zle backward-delete-word
  LBUFFER+="cd $result"
}
