# kaihowl does dotfiles and built upon holman's dotfiles

## Fork

This was forked from holman's excellent base. I added some more vim config and
brushed up the tmux configuration.

## install (reminder)

Run this:

```sh
git clone https://github.com/kaihowl/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
# Actual sourcing/linking of dotfiles and installation
script/bootstrap
# Optionally, run the tests
script/test
```

This will symlink the appropriate files in `.dotfiles` to your home directory.
Everything is configured and tweaked within `~/.dotfiles`.

The main file you'll want to change right off the bat is `zsh/zshrc.symlink`,
which sets up a few paths that'll be different on your particular machine.

## guidelines

- No node.js dependencies.

Reasoning: Indiscriminate dependencies and not part of my day-to-day tech stack.

- CI run in at most 5 minutes.

Reasoning: I am impatient and like my pull requests small and focussed. A longer CI
runtime is counter-productive.

## topical

Everything's built around topic areas. If you're adding a new area to your
forked dotfiles — say, "Java" — you can simply add a `java` directory and put
files in there. Anything with an extension of `.zsh` will get automatically
included into your shell. Anything with an extension of `.symlink` will get
symlinked without extension into `$HOME` when you run `script/bootstrap`.

## what's inside

A lot of stuff. Seriously, a lot of stuff. Check them out in the file browser
above and see what components may mesh up with you.
[Fork it](https://github.com/kaihowl/dotfiles/fork), remove what you don't
use, and build on what you do use.

## components

There are a few special files in the hierarchy.

- **bin/**: Anything in `bin/` will get added to your `$PATH` and be made
  available everywhere.
- **topic/\*.zsh**: Any files ending in `.zsh` get loaded into your
  environment.
- **topic/path.zsh**: Any file named `path.zsh` is loaded first and is
  expected to set up `$PATH` or similar.
- **topic/completion.zsh**: Any file named `completion.zsh` is loaded
  last and is expected to set up autocomplete.
- **topic/\*.symlink**: Any files ending in `*.symlink` get symlinked into
  your `$HOME`. This is so you can keep all of those versioned in your dotfiles
  but still keep those autoloaded files in your home directory. These get
  symlinked in when you run `script/bootstrap`.

## performance

Performance results on [master branch](https://kaihowl.github.io/dotfiles/master.html). 

## thanks

I forked from holman's dotfiles, and he forked [Ryan Bates](http://github.com/ryanb)' excellent
[dotfiles](http://github.com/ryanb/dotfiles). 
