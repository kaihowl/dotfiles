{ lib, pkgs, pkgs-unstable, profile, ... }:
let minimal-packages = with pkgs; [
      universal-ctags
      efm-langserver
      fzf
      git
      git-credential-manager
      ripgrep
      shellcheck
      gcm-helper
      tmux
      zsh expect
      python3
      python3Packages.virtualenv
      python3Packages.virtualenvwrapper
      netcat
      # support tooling
      tree jq htop
      pkgs-unstable.ncdu
      flock
    ]
    # TODO(kaihowl) Double check if reattach-to-user-namespace is still needed
    ++ (lib.optionals pkgs.stdenv.isDarwin [reattach-to-user-namespace coreutils])
    ;
full-packages = with pkgs; [
      alacritty
      ccache
      clang-tools
      cmake
      ninja
      rustup
      # Assumed to be present for Conan tooling
      automake libtool pkg-config
    ]
    ++ (lib.optional pkgs.stdenv.isLinux gdb)
;
in
{
  home = {
    packages = minimal-packages ++ (lib.optionals (profile == "full") full-packages);
    # This actually needs to be your username
    # TODO(kaihowl) remove impurity again?
    username = builtins.getEnv "USER";
    homeDirectory = /. + (builtins.getEnv "HOME");
    stateVersion = "24.05";
  };

  programs = {
    neovim = {
      enable = true;
      plugins= with pkgs.vimPlugins; [
        nvim-lspconfig
      ];
      withNodeJs = false;
      withPython3 = true;
      withRuby = false;
    };

    # TODO(kaihowl) cannot use:;
    # ssh.enable = true;
    # since the address is not an absolute path
    # we unfortunately produce an invalid ssh_config file
    # ssh.matchBlocks = {
    #   "*" = {
    #     localForwards = [{
    #       bind.address = "~/.gcm.socket";
    #       host.address = "~/.gcm.socket";
    #     }];
    #   };
    # };
  };
}
