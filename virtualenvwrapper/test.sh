#!/bin/zsh -ie

echo "Check if 'mkvirtualenv' is available"
which mkvirtualenv

echo "Check if 'workon' is available"
which workon

echo "Test create virtualenv, activate it"
mkvirtualenv mytest
workon mytest
if [[ -z ${VIRTUAL_ENV} ]]; then
  echo "Could not activate virtualenv"
  exit 1
fi

