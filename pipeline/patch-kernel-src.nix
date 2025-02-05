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
  kernelSU,
  susfs,
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
    ''
      export HOME=$(pwd)
    ''
    + (lib.optionalString kernelSU.enable ''
      cp -r ${kernelSU.src} ${kernelSU.subdirectory}
      chmod -R +w ${kernelSU.subdirectory}
      # Force set KernelSU version
      sed -i "/ version:/d" ${kernelSU.subdirectory}/kernel/Makefile
      sed -i "/KSU_GIT_VERSION not defined/d" ${kernelSU.subdirectory}/kernel/Makefile
      sed -i "s|ccflags-y += -DKSU_VERSION=|ccflags-y += -DKSU_VERSION=\"${kernelSU.revision}\"\n#|g" ${kernelSU.subdirectory}/kernel/Makefile
    '')
    + (lib.optionalString susfs.enable ''
      cp -r ${susfs.src}/kernel_patches/fs/* fs/
      cp -r ${susfs.src}/kernel_patches/include/linux/* include/linux/
      chmod -R +w fs include/linux
      patch -p1 < ${susfs.kernelPatch}

      pushd ${kernelSU.subdirectory}
      patch -p1 < ${susfs.kernelsuPatch}
      popd
    '')
    + ''
      patchShebangs .

      # These files may break Wi-Fi
      # https://gitlab.com/simonpunk/susfs4ksu
      rm -f common/android/abi_gki_protected_exports_aarch64
      rm -f common/android/abi_gki_protected_exports_x86_64
    ''
    + (lib.optionalString kernelSU.enable ''
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
