#!/bin/bash
set -e

SCRIPT_DIR=$(unset CDPATH; cd "$(dirname "$0")" > /dev/null; pwd -P)

if [ "$(uname)" == "Darwin" ]; then
  source "${SCRIPT_DIR}/../common/brew.sh"
  # Use --overwrite due to #347, linking of git on GH Actions
  brew_install --overwrite git
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  source "${SCRIPT_DIR}/../common/apt.sh"
  apt_add_repo git-core https://ppa.launchpadcontent.net/git-core/ppa/ubuntu ::codename:: E1DD270288B4E6030699E45FA1715D88E1DF1F24
  apt_install git
fi
