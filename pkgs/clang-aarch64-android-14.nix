{
  stdenv,
  lib,
  callPackage,
  autoPatchelfHook,
  python3,
  bionic,
  zlib,
  libxcrypt-legacy,
  ncurses5,
  bzip2,
}: let
  sources = callPackage ../_sources/generated.nix {};
in
  stdenv.mkDerivation {
    inherit (sources.clang-aarch64-android-14) pname version src;
    sourceRoot = ".";

    nativeBuildInputs = [autoPatchelfHook];
    buildInputs = [python3 bionic zlib libxcrypt-legacy ncurses5 bzip2];

    installPhase = ''
      mkdir -p $out
      cp -r * $out/
    '';
  }
