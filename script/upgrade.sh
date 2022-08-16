#!/bin/zsh
# Shamelessly copied from oh my zsh

printf '\033[0;34m%s\033[0m\n' "Upgrading Dotfiles"
cd "$DOTS" || exit 1
oldcommit=$(git rev-parse master)
if git fetch origin && git rebase origin/master master
then
  newcommit=$(git rev-parse master)
  if [[ $oldcommit != "$newcommit" ]]; then
    printf '\033[0;34m%s\033[0m\n' 'Dotfiles updated to current version.'
  else
    printf '\033[0;34m%s\033[0m\n' 'No updates found.'
  fi

  printf '\033[0;34m%s\033[0m\n' 'Requesting sudo for bootstrap/install.'
  sudo /usr/bin/true
  printf '\033[0;34m%s\033[0m\n' "Running bootstrap..."
  ./script/bootstrap
  printf '\033[0;34m%s\033[0m\n' 'Running install...'
  ./script/install

  if ! git --no-pager diff --exit-code master..origin/master > /dev/null; then
    printf '\033[0;31m%s\033[0m\n' 'You have pending, local changes. Use dot-export or push them.'
  fi
else
  printf '\033[0;31m%s\033[0m\n' 'There was an error updating. Try again later?'
fi
