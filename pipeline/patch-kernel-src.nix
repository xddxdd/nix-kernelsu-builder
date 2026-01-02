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
  bbg,
  prePatch,
  postPatch,
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

  inherit prePatch;
  postPatch = ''
    export HOME=$(pwd)
  ''
  + (lib.optionalString kernelSU.enable ''
    cp -r ${kernelSU.src} ${kernelSU.subdirectory}
    chmod -R +w ${kernelSU.subdirectory}
  '')
  + (lib.optionalString susfs.enable ''
    cp -r ${susfs.src}/kernel_patches/fs/* fs/
    cp -r ${susfs.src}/kernel_patches/include/linux/* include/linux/
    chmod -R +w fs include/linux
  '')
  + (lib.optionalString (susfs.enable && susfs.kernelPatch != null) ''
    echo "applying patch ${susfs.kernelPatch}"
    patch -p1 < ${susfs.kernelPatch}
  '')
  + (lib.optionalString (susfs.enable && susfs.kernelsuPatch != null) ''
    pushd ${kernelSU.subdirectory}
    echo "applying patch ${susfs.kernelsuPatch}"
    patch -p1 < ${susfs.kernelsuPatch}
    popd
  '')
  # BBG integration NOTE:
  # For GKI/modern kernels, simply enabling CONFIG_BBG=y is NOT sufficient.
  # The Baseband-guard Makefile enforces a check to ensure "baseband_guard" is
  # explicitly present in the CONFIG_LSM list. If it is missing, the build
  # will fail with a "Please follow Baseband-guard's README" error.
  # You MUST manually append ",baseband_guard" to the CONFIG_LSM string in
  # your kernelConfig (e.g., CONFIG_LSM="...,bpf,baseband_guard").
  + (lib.optionalString bbg.enable ''
    echo "Integrating Baseband-guard..."
    mkdir -p security/baseband-guard
    cp -r ${bbg.src}/* security/baseband-guard/
    chmod -R +w security/baseband-guard

    if [ -f security/Makefile ] && ! grep -q "baseband-guard" security/Makefile; then
      echo "Adding BBG to security/Makefile"
      echo "obj-\$(CONFIG_BBG) += baseband-guard/" >> security/Makefile
    fi

    if [ -f security/Kconfig ] && ! grep -q "security/baseband-guard/Kconfig" security/Kconfig; then
      echo "Adding BBG to security/Kconfig"
      awk '
        { a[NR]=$0 } END{
          last=0; for(i=1;i<=NR;i++) if(a[i] ~ /^endmenu[[:space:]]*$/) last=i;
          for(i=1;i<=NR;i++){
            if(i==last) print "source \"security/baseband-guard/Kconfig\"";
            print a[i];
          }
        }' security/Kconfig > security/Kconfig.tmp && mv security/Kconfig.tmp security/Kconfig
    fi
  '')
  + ''
    patchShebangs .

    # These files may break Wi-Fi
    # https://gitlab.com/simonpunk/susfs4ksu
    rm -f common/android/abi_gki_protected_exports_*
    rm -f msm-kernel/android/abi_gki_protected_exports_*
  ''
  + (lib.optionalString kernelSU.enable ''
    # Force set KernelSU version
    sed -i "/ version:/d" ${kernelSU.subdirectory}/kernel/Makefile
    sed -i "/KSU_GIT_VERSION not defined/d" ${kernelSU.subdirectory}/kernel/Makefile
    sed -i "s|ccflags-y += -DKSU_VERSION=|ccflags-y += -DKSU_VERSION=\"${kernelSU.revision}\"\n#|g" ${kernelSU.subdirectory}/kernel/Makefile

    bash ${kernelSU.subdirectory}/kernel/setup.sh
  '')
  + ''
    sed -i "s|/bin/||g" Makefile
  ''
  + postPatch;

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r * $out/

    runHook postInstall
  '';

  dontFixup = true;
}
