export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/Devel
# Set explicitly, even if we expect this python3 to be the first python3 on the PATH already
export VIRTUALENVWRAPPER_PYTHON=$HOME/.nix-profile/bin/python3
export VIRTUALENVWRAPPER_VIRTUALENV=$HOME/.nix-profile/bin/virtualenv

nix_virtualenv_scripts=~/.nix-profile/bin
lazy_wrapper=virtualenvwrapper_lazy.sh
if [ -f "${nix_virtualenv_scripts}/${lazy_wrapper}" ]; then
  # shellcheck disable=SC1090
  source "${nix_virtualenv_scripts}/${lazy_wrapper}"
else
  echo -e "Could not find virtualenvwrapper_lazy"
fi
