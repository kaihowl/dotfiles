#!/bin/bash
set -e

function apt_install() {
  sudo apt-get install --upgrade -y "$@"
}
