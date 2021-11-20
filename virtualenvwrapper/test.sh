#!/bin/zsh -ix
# Deliberately not set -e as the virtualenvwrapper functions inherit this.
# I could not get the test to pass with it activated. If the actual expectations
# of this test are not met, the test will still reliably fail, though.

echo "Check: VIRTUALENVWRAPPER_PYTHON: ${VIRTUALENVWRAPPER_PYTHON}"

echo "Check if 'mkvirtualenv' is available"
which mkvirtualenv
if [ $? != 0 ]; then
  echo "Failed to find mkvirtualenv"
  exit 1
fi

echo "Check if 'workon' is available"
which workon
if [ $? != 0 ]; then
  echo "Failed to find workon";
  exit 1
fi

echo "Test create virtualenv, activate it"
mktmpenv
if [ $? != 0 ]; then
  echo "Failed to execute mktmpenv"
  exit 1
fi

if [[ -z ${VIRTUAL_ENV} ]]; then
  echo "Could not activate virtualenv"
  exit 1
fi

deactivate
if [ $? != 0 ]; then
  echo "Failed to execute deactivate"
  exit 1
fi
