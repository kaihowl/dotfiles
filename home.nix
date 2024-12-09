{ lib, pkgs, pkgs-unstable, profile, ... }:
let
  # Use the existing python-lsp-server and extend its runtime environment
  python-lsp-server-with-plugins = pkgs.stdenvNoCC.mkDerivation rec {
    name = "python-lsp-server-with-plugins";
    src = null; # No source required, just wrapping

    nativeBuildInputs = [ pkgs.makeWrapper ];

    buildInputs = with pkgs.python3Packages; [
      python-lsp-server
      # rest is "all"
      autopep8
      flake8
      mccabe
      pycodestyle
      pydocstyle
      pyflakes
      pylint
      rope
      toml
      whatthepatch
      yapf
      # external plugin
      python-lsp-black
    ];

    unpackPhase = ":";

    # Only expose pylsp.
    installPhase = ''
      mkdir -p $out/bin
      cp ${pkgs.python3Packages.python-lsp-server}/bin/pylsp $out/bin/
      wrapProgram $out/bin/pylsp \
        --prefix PYTHONPATH : ${pkgs.python3.pkgs.makePythonPath buildInputs}
    '';
};
minimal-packages = with pkgs; [
      universal-ctags
      efm-langserver
      fzf
      git
      git-credential-manager
      ripgrep
      shellcheck
      gcm-helper
      tmux
      zsh
      zsh-powerlevel10k
      zsh-autocomplete
      zsh-autosuggestions
      zsh-z
      expect # Needed for testing
      python3
      python3Packages.virtualenv
      python3Packages.virtualenvwrapper
      python-lsp-server-with-plugins
      netcat
      vim-vint
      # Needs to be at least 0.3.0 to support token by git-credentials
      pkgs-unstable.revup
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
        rust-tools-nvim
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
