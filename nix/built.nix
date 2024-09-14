{ elm2nix, minimalElmSrc, pkgs, stdenv }:
stdenv.mkDerivation {
  name = "json-to-elm-test-values";
  src = minimalElmSrc;
  # build-time-only dependencies
  nativeBuildDeps = [ ];
  # runtime dependencies
  buildDeps = [ ];
  buildPhase = ''
    patchShebangs *.sh
    cat >./dist/context.js <<EOF
    // This file generated within flake.nix

    window.appContext = {
        nix: {
          outPath: null,
        },
    }
    EOF
  '';
  installPhase = ''
    mkdir -p $out
    cp -r dist/* $out/
    cp ${elm2nix}/*.js $out/
  '';
}
