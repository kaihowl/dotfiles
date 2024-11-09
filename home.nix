{ lib, pkgs, pkgs-unstable, ... }:
{
  home = {
    packages = with pkgs; [
      alacritty
      ccache
      clang-tools
      cmake
      universal-ctags
      efm-langserver
      fzf
      git
      ninja
      neovim-unwrapped
      ripgrep
      rustup
      shellcheck
      tmux
      zsh expect
      python3
      python3Packages.virtualenv
      python3Packages.virtualenvwrapper
      python3Packages.pip
      # support tooling
      tree jq htop
      pkgs-unstable.ncdu
      flock
      # Assumed to be present for Conan tooling
      automake libtool pkg-config
    ]
    ++ (lib.optional pkgs.stdenv.isLinux gdb)
    # TODO(kaihowl) Double check if reattach-to-user-namespace is still needed
    ++ (lib.optionals pkgs.stdenv.isDarwin [reattach-to-user-namespace coreutils])
    ;

    # This actually needs to be your username
    # TODO(kaihowl) remove impurity again?
    username = builtins.getEnv "USER";
    homeDirectory = /. + (builtins.getEnv "HOME");

    stateVersion = "24.05";
  };
}
