export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/Devel
# Missing expansion of VIRTUALENVWRAPPER_PYTHON
# This needs to be specific to each platform, i.e., where python3 sits.
# Set this instead in your .zprofile if not set by install.sh automatically.

macos_virtualenv_scripts=/usr/local/bin
macos_alternative_scripts=/opt/homebrew/bin/
ubuntu_virtualenv_scripts=/usr/share/virtualenvwrapper
lazy_wrapper=virtualenvwrapper_lazy.sh
if [ -f "${macos_virtualenv_scripts}/${lazy_wrapper}" ]; then
  # shellcheck disable=SC1090
  source "${macos_virtualenv_scripts}/${lazy_wrapper}"
elif [ -f "${macos_alternative_scripts}/${lazy_wrapper}" ]; then
  # shellcheck disable=SC1090
  source "${macos_alternative_scripts}/${lazy_wrapper}"
elif [ -f "${ubuntu_virtualenv_scripts}/${lazy_wrapper}" ]; then
  # shellcheck disable=SC1090
  source "${ubuntu_virtualenv_scripts}/${lazy_wrapper}"
else
  echo -e "Could not find virtualenvwrapper_lazy"
fi
