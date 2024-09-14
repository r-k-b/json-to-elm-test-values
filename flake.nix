{
  description = "json-to-elm-test-values";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let supportedSystems = with flake-utils.lib.system; [ x86_64-linux ];
    in flake-utils.lib.eachSystem supportedSystems (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (pkgs) lib stdenv callPackage;
        inherit (lib) fileset hasInfix hasSuffix;

        toSource = fsets:
          fileset.toSource {
            root = ./.;
            fileset = fileset.unions fsets;
          };

        # The build cache will be invalidated if any of the files within change.
        # So, exclude files from here unless they're necessary for `elm make` et al.
        minimalElmSrc = toSource [
          (fileset.fileFilter (file: file.hasExt "elm") ./src)
          ./dist
          ./elm.json
          ./nix/elm/registry.dat
        ];

        failIfDepsOutOfSync =
          callPackage ./nix/failIfDepsOutOfSync.nix { inherit minimalElmSrc; };

        elm2nix = callPackage ./nix/default.nix { inherit minimalElmSrc; };

        built = callPackage ./nix/built.nix { inherit elm2nix minimalElmSrc; };

        peekSrc = name: src:
          stdenv.mkDerivation {
            src = src;
            name = "peekSource-${name}";
            buildPhase = "mkdir -p $out";
            installPhase = "cp -r ./* $out";
          };
      in {
        packages = {
          inherit built;
          default = built;
          rawElm2Nix = elm2nix;
          minimalElmSrc = peekSrc "minimal-elm" minimalElmSrc;
        };
        checks = { inherit built failIfDepsOutOfSync; };
        devShells.default = callPackage ./nix/shell.nix { };
        apps.default = {
          type = "app";
          program = "${pkgs.writeScript "j2etvApp" ''
            #!${pkgs.bash}/bin/bash

            xdg-open ${built}/index.html
          ''}";
        };
        packages = { };
      });
}
