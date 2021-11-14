function ensure_pip_installed() {
  if [[ "$(uname)" == "Linux" && "$(lsb_release -i)" == *"Ubuntu"* ]]; then
    if test ! "$(python3 -m pip)"
    then
      source $DOTS/common/apt.sh
      apt_install --no-install-recommends python3-pip
    fi
  fi
}
