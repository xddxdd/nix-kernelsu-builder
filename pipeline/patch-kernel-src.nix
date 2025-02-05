{
  stdenv,
  lib,
  writeShellScriptBin,
  coreutils,
  perl,
  python3,
  # User args
  src,
  patches,
  enableKernelSU,
  kernelSU,
  ...
}:
let
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

      cp -r ${kernelSU.src} ${kernelSU.subdirectory}
      chmod -R +w ${kernelSU.subdirectory}
      # Force set KernelSU version
      sed -i "/ version:/d" ${kernelSU.subdirectory}/kernel/Makefile
      sed -i "/KSU_GIT_VERSION not defined/d" ${kernelSU.subdirectory}/kernel/Makefile
      sed -i "s|ccflags-y += -DKSU_VERSION=|ccflags-y += -DKSU_VERSION=\"${kernelSU.revision}\"\n#|g" ${kernelSU.subdirectory}/kernel/Makefile
    '')
    + ''
      patchShebangs .
    ''
    + (lib.optionalString enableKernelSU ''
      bash ${kernelSU.subdirectory}/kernel/setup.sh
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
