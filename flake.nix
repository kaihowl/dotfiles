{
  description = "My home manager configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";

    nixpkg-unstable.url = "nixpkgs/nixos-unstable";

    nixpkgs-prev.url = "nixpkgs/nixos-24.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, nixpkg-unstable, nixpkgs-prev, ... }:
    let
      lib = nixpkgs.lib;
      # https://github.com/NixOS/nix/issues/3978#issuecomment-1676001388
      # Do not want multiple lock files, therefore not as part of "inputs"
      gcm-flake = import ./gcm/flake.nix;
      gcm-helper = gcm-flake.outputs {
        self = gcm-flake.outputs;
        inherit nixpkgs;
      };
      system = builtins.currentSystem;
      pkgs = import nixpkgs { inherit system; overlays = [ gcm-helper.overlay ]; };
      pkgs-unstable = import nixpkg-unstable { inherit system; };
      pkgs-prev = import nixpkgs-prev { inherit system; };
    in {
      homeConfigurations = {
        full = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {inherit pkgs-unstable; inherit pkgs-prev; profile="full";};
          modules = [ ./home.nix ];
        };
        minimal = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {inherit pkgs-unstable; inherit pkgs-prev; profile="minimal";};
          modules = [ ./home.nix ];
        };
      };
    };
}
