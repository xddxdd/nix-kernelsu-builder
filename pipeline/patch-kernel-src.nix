{
  stdenv,
  callPackage,
  writeShellScriptBin,
  # User args
  src,
  patches,
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

    postPatch = ''
      cp -r ${sources.kernelsu-stable.src} KernelSU
      chmod -R +w KernelSU
      patchShebangs .
      bash KernelSU/kernel/setup.sh
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
