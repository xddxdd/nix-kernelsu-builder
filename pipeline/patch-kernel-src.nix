{
  stdenv,
  lib,
  callPackage,
  writeShellScriptBin,
  # User args
  src,
  patches,
  enableKernelSU,
  ...
}: let
  sources = callPackage ../_sources/generated.nix {};

  fakeGit = writeShellScriptBin "git" ''
    exit 0
  '';
in
  stdenv.mkDerivation {
    name = "patched-kernel";
    inherit src patches;

    nativeBuildInputs = [fakeGit];

    postPatch =
      (lib.optionalString enableKernelSU ''
        cp -r ${sources.kernelsu-stable.src} KernelSU
        chmod -R +w KernelSU
      '')
      + ''
        patchShebangs .
      ''
      + (lib.optionalString enableKernelSU ''
        bash KernelSU/kernel/setup.sh
      '')
      + ''
        sed -i "s|/bin/||g" Makefile
      '';

    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r * $out/

      runHook postInstall
    '';

    dontFixup = true;
  }
