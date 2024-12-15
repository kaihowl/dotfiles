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
        plenary-nvim
        kotlin-vim
        markdown-preview-nvim
        vim-fugitive
        vim-rhubarb # github fugitive completion handler
        vim-unimpaired
        vim-repeat
        vim-surround
        vim-abolish
        indent-blankline-nvim
        vim-trailing-whitespace
        vim-tmux-navigator
        tabular
        vim-sneak
        vim-gitgutter
        tagbar
        vim-addon-local-vimrc
        asyncrun-vim
        asynctasks-vim
        fzf-lua
        tcomment_vim

        # Color schemes
        edge
        gruvbox
        tokyonight-nvim
        onehalf
        papercolor-theme
        # TODO(kaihowl) archived repo
        (pkgs.vimUtils.buildVimPlugin {
          pname = "nvim-juliana";
          version = "2024-01-25";
          src = pkgs.fetchFromGitHub {
            owner = "kaiuri";
            repo = "nvim-juliana";
            rev = "881d1a85d33f744b6b851a210becb3194da8e2a6";
            # Determine with
            # nix-prefetch-url --unpack https://github.com/kaiuri/nvim-juliana/archive/881d1a85d33f744b6b851a210becb3194da8e2a6.tar.gz
            sha256 = "0hw18bxwjkv3s2d814v3avmakvvm4a1f22n5xc87iayw8zsyn0kk";
          };
         })
        (pkgs.vimUtils.buildVimPlugin {
          pname = "github.vim"; # Color scheme for github
          version = "2022-04-03";
          src = pkgs.fetchFromGitHub {
            owner = "1612492";
            repo = "github.vim";
            rev = "35368f952bda654b82d69c2770510696c781ac32";
            # Determine with
            # nix-prefetch-url --unpack https://github.com/1612492/github.vim/archive/35368f952bda654b82d69c2770510696c781ac32.tar.gz
            sha256 = "0qaqwmfs6bs3idlrcqajcj66cw2vz0pxdpd70js9nj5028dwkirh";
          };
         })

        # Completion plugins
        nvim-cmp
        cmp-nvim-lsp
        cmp-buffer
        cmp-vsnip
        vim-vsnip
        vim-vsnip-integ
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
