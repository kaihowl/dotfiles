#!/bin/bash

set -ex

echo "pwd rhel_build.sh start: $(pwd)"

export GIT_PERF_DISABLED=true
env
yum install -y git
echo "pwd rhel_build.sh middle: $(pwd)"
# TODO Check centos
export XDG_CONFIG_HOME=~/.config
# Make `infocmp` for nvim healthcheck succeed
export TERM=dumb
# Ignore potentially insecure directories on GitHub actions runner.
export ZSH_DISABLE_COMPFIX=true
echo "pwd rhel_build.sh hand over: $(pwd)"
./script/ci.sh
