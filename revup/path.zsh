# Exporting PATH to `~/.virtualenvs/revup/bin` is not correct; it also exposes the
# python3 from the virtualenv.
# Using `hash -p` is also not advisable as a change to the PATH could reset this hashmap.
# Creating an empty dir, symlinking the revup binary there, and expose that directory is
# unnecessarily more complex.
revup () {
    "$HOME/.virtualenvs/revup/bin/revup" "$@"
}
