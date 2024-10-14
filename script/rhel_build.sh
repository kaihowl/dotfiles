#!/bin/bash

set -ex

export GIT_PERF_DISABLED=true
env
yum install -y git
# TODO Check centos
export XDG_CONFIG_HOME=~/.config
# Make `infocmp` for nvim healthcheck succeed
export TERM=dumb
# Ignore potentially insecure directories on GitHub actions runner.
export ZSH_DISABLE_COMPFIX=true
pwd
./script/ci.sh
