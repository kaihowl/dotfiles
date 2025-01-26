{
  description = "My home manager configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";

    nixpkgs-prev.url = "nixpkgs/nixos-24.05";

    # Also update versions in nix/install.sh and Makefile
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, nixpkgs-prev, ... }:
    let
      lib = nixpkgs.lib;
      lic = import ./lic.nix;
      # https://github.com/NixOS/nix/issues/3978#issuecomment-1676001388
      # Do not want multiple lock files, therefore not as part of "inputs"
      gcm-flake = import ./gcm/flake.nix;
      gcm-helper = gcm-flake.outputs {
        self = gcm-flake.outputs;
        inherit nixpkgs;
      };
      system = builtins.currentSystem;
      pkgs = import nixpkgs { inherit system; overlays = [ gcm-helper.overlay ]; };
      pkgs-prev = import nixpkgs-prev { inherit system; };
      home-manager-pkg = home-manager.defaultPackage.${system};
    in rec {
      apps.${system}.home-manager = {
        type = "app";
        program = "${home-manager-pkg}/bin/home-manager";
      };
      homeConfigurations = {
        full = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit pkgs-prev;
            inherit home-manager-pkg;
            profile="full";
          };

          modules = [ ./home.nix ];
        };
        minimal = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit pkgs-prev;
            inherit home-manager-pkg;
            profile="minimal";
          };

          modules = [ ./home.nix ];
        };
      };

      licenses = rec {
        badDeps = (lic.keepBadDeps homeConfigurations.full.config.home.packages);
      };

      checks.${system}.licenses =  assert licenses.badDeps == []; pkgs.runCommand "nop" {} "mkdir $out/";
    };
}
