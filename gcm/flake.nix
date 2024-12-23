{
  description = "gcm-helper";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "nixpkgs/nixos-24.11";

  outputs = { self, nixpkgs }:
    let

      # to work with older version of flakes
      lastModifiedDate = self.lastModifiedDate or self.lastModified or "19700101";

      # Generate a user-friendly version number.
      version = builtins.substring 0 8 lastModifiedDate;

      # System types to support.
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ self.overlay ]; });

    in

    {

      # A Nixpkgs overlay.
      overlay = final: prev: {

        gcm-helper = with final; stdenvNoCC.mkDerivation rec {
          name = "gcm-helper-${version}";

          unpackPhase = ":";

          buildInputs = [
            (python3.withPackages (ppkgs: [
              ppkgs.python-daemon
            ]))
          ];

          src = ./.;

          installPhase =
            ''
              mkdir -p $out/bin
              cp $src/gcm-server $src/gcm-client $out/bin/
            '';

          postInstall = 
            ''
            substituteAll $out/gcm-client $out/gcm-server
              --replace-fail "/usr/bin/env python3" "${python3.out}/bin/python3"
            '';
        };

      };

      # Provide some binary packages for selected system types.
      packages = forAllSystems (system:
        {
          inherit (nixpkgsFor.${system}) gcm-helper;
        });

      # The default package for 'nix build'. This makes sense if the
      # flake provides only one package or there is a clear "main"
      # package.
      defaultPackage = forAllSystems (system: self.packages.${system}.gcm-helper);
    };
}
