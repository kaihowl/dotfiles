#!/bin/bash
set -e

function apt_install() {
  sudo apt-get install --upgrade -y "$@"
}

function apt_remove() {
  sudo apt-get remove -y "$@"
}
