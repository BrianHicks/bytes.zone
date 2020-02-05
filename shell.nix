{ ... }:
let
  sources = import ./nix/sources.nix;
  nixpkgs = import sources.nixpkgs { config.allowUnfree = true; };
  niv = import sources.niv { };

  # we need some additional header files on macos
  macosDeps = [ nixpkgs.darwin.apple_sdk.frameworks.CoreServices ];
in with nixpkgs;
stdenv.mkDerivation {
  name = "bytes.zone";
  buildInputs = [
    # base deps
    niv.niv
    git

    # for elm-pages
    nodejs
    nodePackages.npm

    # for sharp
    vips

    # for font subsetting
    (python3.withPackages (ps: [ ps.fonttools ps.brotli ps.black ]))
  ] ++ lib.optionals stdenv.isDarwin macosDeps;
}
