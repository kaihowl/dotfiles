{
  description = "My home manager configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";

    nixpkg-unstable.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, nixpkg-unstable, ... }:
    let
      lib = nixpkgs.lib;
      system = builtins.currentSystem;
      pkgs = import nixpkgs { inherit system; };
      pkgs-unstable = import nixpkg-unstable { inherit system; };
    in {
      homeConfigurations = {
        myprofile = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {inherit pkgs-unstable;};
          modules = [ ./home.nix ];
        };
      };
    };
}
