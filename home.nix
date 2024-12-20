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
    ++ (lib.optional pkgs.stdenv.isDarwin coreutils)
    # need up to date ssh-keygen for newer git version and signing of commits
    ++ (lib.optional pkg.stdenv.isLinux openssh)
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
    # NOTE this is the reason for the impurity
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

        # Carbon offers:
        # - auto update based on file system watchers
        # - intuitive addition of new files / directories
        # - performance
        (pkgs.vimUtils.buildVimPlugin {
          pname = "cabon-nvim"; # Color scheme for github
          version = "0.20.2";
          src = pkgs.fetchFromGitHub {
            owner = "SidOfc";
            repo = "carbon.nvim";
            rev = "44885f9ef558566640c37edc0eceb30a0dcddc48";
            # Determine with
            # nix-prefetch-url --unpack https://github.com/SidOfc/carbon.nvim/archive/44885f9ef558566640c37edc0eceb30a0dcddc48.tar.gz
            sha256 = "0zk4vlmimmrw0hd02lxmch563lf9gv05a3n03qq00g1nh892fim9";
          };
         })

        (pkgs.vimUtils.buildVimPlugin {
          pname = "oil-nvim"; # Color scheme for github
          version = "2.13.0";
          src = pkgs.fetchFromGitHub {
            owner = "stevearc";
            repo = "oil.nvim";
            rev = "50c4bd4ee216f08907f64d0295c0663a69e58ffb";
            # Determine with
            # nix-prefetch-url --unpack https://github.com/stevearc/oil.nvim/archive/50c4bd4ee216f08907f64d0295c0663a69e58ffb.tar.gz
            sha256 = "0zp4i4gg1xm4vpxv1jp1hr4i49h5xq04sbgqm7q0a82b586j4y2y";
          };
         })

        (pkgs.vimUtils.buildVimPlugin {
          pname = "linediff-vim"; # Color scheme for github
          version = "0.2.0";
          src = pkgs.fetchFromGitHub {
            owner = "vim-scripts";
            repo = "linediff.vim";
            rev = "b1ad2f1faecc09daf8defcc2e4481335092ec0dc";
            # Determine with
            # nix-prefetch-url --unpack https://github.com/vim-scripts/linediff.vim/archive/b1ad2f1faecc09daf8defcc2e4481335092ec0dc.tar.gz
            sha256 = "0d6hj2kdp39zcrva0gxavjb2a1w7x5sf03majks47rypsgj358i0";
          };
         })

        (pkgs.vimUtils.buildVimPlugin {
          pname = "vim-indent-sentence"; # Color scheme for github
          version = "2014-09-04";
          src = pkgs.fetchFromGitHub {
            owner = "kaihowl";
            repo = "vim-indent-sentence";
            rev = "87069e15148ad0f27e7b070bc7e123da6050e147";
            # Determine with
            # nix-prefetch-url --unpack https://github.com/kaihowl/vim-indent-sentence/archive/87069e15148ad0f27e7b070bc7e123da6050e147.tar.gz
            sha256 = "1qg8c2fcgvv200ibdmm37yr57js99mci5xavdlxmb5nrjp88amld";
          };
         })

        (pkgs.vimUtils.buildVimPlugin {
          pname = "vim-textobj-argument"; # Color scheme for github
          version = "2013-02-23";
          src = pkgs.fetchFromGitHub {
            owner = "gaving";
            repo = "vim-textobj-argument";
            rev = "179a8d42e73df72ba32d6c641f4edc0def59e0cb";
            # Determine with
            # nix-prefetch-url --unpack https://github.com/gaving/vim-textobj-argument/archive/179a8d42e73df72ba32d6c641f4edc0def59e0cb.tar.gz
            sha256 = "18dngkm98rwyjxzjidpqzz7hcq600akyd1j6m2aybcazg73is6pp";
          };
         })

        # Color schemes
        edge
        gruvbox
        tokyonight-nvim
        onehalf
        papercolor-theme
        # NOTE archived repo
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
