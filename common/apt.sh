#!/bin/bash
set -e

function apt_install() {
  sudo apt-get install --upgrade -y "$@"
}

function apt_remove() {
  sudo apt-get remove -y "$@"
}

# Replace add-apt-repository with safer variant:
# Use pinned key and only use key for the package it was intended for.
# apt-key and apt-add-repository are deprecated.
# Usage apt_add_repo name uri suite key
# Both uri and suite understand {{codename}} as a template that is replaced by Ubuntu codename. E.g., bionic.
function apt_add_repo() {
  local name
  name=$1
  if [ -z "$name" ]; then
    echo Missing name
    exit 1
  fi
  local codename
  codename=$(lsb_release -cs)
  local uri
  uri=${2//::codename::/$codename}
  if [ -z "$uri" ]; then
    echo Missing uri
    exit 1
  fi
  local suite
  suite=${3//::codename::/$codename}
  if [ -z "$suite" ]; then
    echo Missing suite
    exit 1
  fi
  local key_id
  key_id=$4
  if [ -z "$key_id" ]; then
    echo Missing key id
    exit 1
  fi

  local keyring_dir
  keyring_dir=/etc/apt/keyrings
  local keyring
  keyring=$keyring_dir/$name

  local list_name
  list_name=/etc/apt/sources.list.d/$name.list

  apt_install gpg ca-certificates lsb-release
  sudo mkdir -p "$keyring_dir"
  sudo gpg --homedir /tmp --batch --keyserver keyserver.ubuntu.com --no-default-keyring --keyring "$keyring" --receive-keys "$key_id"
  echo "deb [signed-by=$keyring] $uri $suite main" | sudo tee "$list_name"
  echo "deb-src [signed-by=$keyring] $uri $suite main" | sudo tee -a "$list_name"
  sudo apt-get update
}
