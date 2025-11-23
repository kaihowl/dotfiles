{
  description = "My home manager configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.05";

    nixpkgs-prev.url = "nixpkgs/nixos-24.11";

    # Also update versions in nix/install.sh and Makefile
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, nixpkgs-prev, ... }:
    let
      lib = nixpkgs.lib;
      lic = import ./lic.nix;

      # Support multiple systems
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = f: lib.genAttrs supportedSystems (system: f system);

      # Per-system package sets
      pkgsFor = forAllSystems (system:
        let
          # https://github.com/NixOS/nix/issues/3978#issuecomment-1676001388
          # Do not want multiple lock files, therefore not as part of "inputs"
          gcm-flake = import ./gcm/flake.nix;
          gcm-helper = gcm-flake.outputs {
            self = gcm-flake.outputs;
            inherit nixpkgs;
          };
        in
        # Disable testing to prevent having nmt as part of neovim dynamically fetched but not gc-pinned
        import nixpkgs { inherit system; overlays = [ gcm-helper.overlay ]; config = {doCheck=false;};}
      );

      pkgsPrevFor = forAllSystems (system:
        import nixpkgs-prev { inherit system; config = {doCheck=false;};}
      );

      collectFlakeInputs = input:
        [ input ] ++ builtins.concatMap collectFlakeInputs (builtins.attrValues (input.inputs or {}));

      # Helper to create homeConfiguration for a given system
      mkHomeConfiguration = system: profile:
        let
          pkgs = pkgsFor.${system};
          pkgs-prev = pkgsPrevFor.${system};
          home-manager-pkg = home-manager.packages.${system}.default;
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit pkgs-prev;
            inherit home-manager-pkg;
            inherit profile;
          };

          modules = [
            ./home.nix
            # Pass username and homeDirectory from environment at runtime
            { config, ... }: {
              home.username = builtins.getEnv "USER";
              home.homeDirectory = /. + (builtins.getEnv "HOME");
            }
          ];
        };
    in rec {
      packages = forAllSystems (system: {
        default = pkgsFor.${system}.buildEnv {
          name = "gc-root";
          paths = builtins.attrValues self.inputs;
        };
      });

      apps = forAllSystems (system: {
        home-manager = {
          type = "app";
          program = "${home-manager.packages.${system}.default}/bin/home-manager";
        };
      });

      homeConfigurations = builtins.listToAttrs (
        builtins.concatMap (system: [
          {
            name = "full-${system}";
            value = mkHomeConfiguration system "full";
          }
          {
            name = "minimal-${system}";
            value = mkHomeConfiguration system "minimal";
          }
        ]) supportedSystems
      );

      licenses = forAllSystems (system: rec {
        badDeps = (lic.keepBadDeps homeConfigurations."full-${system}".config.home.packages);
      });

      checks = forAllSystems (system: {
        licenses = assert licenses.${system}.badDeps == []; pkgsFor.${system}.runCommand "nop" {} "mkdir $out/";
      });

    };
}
