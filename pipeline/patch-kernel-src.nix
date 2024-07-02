{
  stdenv,
  lib,
  callPackage,
  writeShellScriptBin,
  coreutils,
  perl,
  python3,
  # User args
  src,
  patches,
  enableKernelSU,
  ...
}:
let
  sources = callPackage ../_sources/generated.nix { };

  fakeGit = writeShellScriptBin "git" ''
    exit 0
  '';
in
stdenv.mkDerivation {
  name = "patched-kernel";
  inherit src patches;

  nativeBuildInputs = [
    coreutils
    fakeGit
    perl
    python3
  ];

  postPatch =
    (lib.optionalString enableKernelSU ''
      export HOME=$(pwd)

      cp -r ${sources.kernelsu-stable.src} KernelSU
      chmod -R +w KernelSU
      # Force set KernelSU version
      sed -i "/KernelSU version:/d" KernelSU/kernel/Makefile
      sed -i "/KSU_GIT_VERSION not defined/d" KernelSU/kernel/Makefile
      sed -i "s|ccflags-y += -DKSU_VERSION=|ccflags-y += -DKSU_VERSION=\"${sources.kernelsu-stable-revision-code.version}\"\n#|g" KernelSU/kernel/Makefile
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
