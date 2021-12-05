#!/bin/zsh -lix
# shellcheck shell=bash
# Deliberately not set -e as the virtualenvwrapper functions inherit this.
# I could not get the test to pass with it activated. If the actual expectations
# of this test are not met, the test will still reliably fail, though.
# This has to be a login shell to read .zprofile.
# This has to be an interactive shell to read workon.zsh.

echo "Check: VIRTUALENVWRAPPER_PYTHON: ${VIRTUALENVWRAPPER_PYTHON}"

echo "Check if 'mkvirtualenv' is available"
which mkvirtualenv
if ! which mkvirtualenv; then
  echo "Failed to find mkvirtualenv"
  exit 1
fi

echo "Check if 'workon' is available"

if ! which workon; then
  echo "Failed to find workon";
  exit 1
fi

echo "Test create virtualenv, activate it"
if ! mktmpenv; then
  echo "Failed to execute mktmpenv"
  exit 1
fi

if [[ -z ${VIRTUAL_ENV} ]]; then
  echo "Could not activate virtualenv"
  exit 1
fi

if ! deactivate; then
  echo "Failed to execute deactivate"
  exit 1
fi
