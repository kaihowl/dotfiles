#!/usr/bin/env zsh
# Shamelessly copied from oh my zsh

cd "$DOTS" || exit 1

upstream_branch=$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' || echo 'NO BRANCH') 
if [[ $upstream_branch != 'origin/master' ]]; then
  printf '\033[0;31m%s\033[0m\n' 'Not on master branch. Failing auto update.'
  exit 0
fi

printf '\033[0;34m%s\033[0m\n' "Upgrading Dotfiles"

printf '\033[0;34m%s\033[0m\n' 'Requesting sudo for bootstrap/install.'
sudo /usr/bin/true

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
  DOTS_UPGRADE=true ./script/bootstrap

  if ! git --no-pager diff --exit-code master..origin/master > /dev/null; then
    printf '\033[0;31m%s\033[0m\n' 'You have pending, local changes. Use dot-export or push them.'
  fi
else
  printf '\033[0;31m%s\033[0m\n' 'There was an error updating. Try again later?'
fi
