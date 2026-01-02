{
  pkgs,
  lib,
  stdenv,
  bc,
  bison,
  coreutils,
  cpio,
  elfutils,
  flex,
  gmp,
  kmod,
  libmpc,
  mpfr,
  nettools,
  openssl,
  pahole,
  perl,
  python3,
  rsync,
  ubootTools,
  which,
  zlib,
  zstd,
  # User args
  src,
  arch,
  defconfigs,
  kernelSU,
  susfs,
  bbg,
  makeFlags,
  additionalKernelConfig ? "",
  ...
}:
let
  gcc-aarch64-linux-android = pkgs.callPackage ../pkgs/gcc-aarch64-linux-android.nix { };
  gcc-arm-linux-androideabi = pkgs.callPackage ../pkgs/gcc-arm-linux-androideabi.nix { };

  finalMakeFlags = [
    "ARCH=${arch}"
    "CROSS_COMPILE=aarch64-linux-android-"
    "CROSS_COMPILE_ARM32=arm-linux-androideabi-"
    "O=$out"
  ]
  ++ makeFlags;

  defconfig = lib.last defconfigs;
  kernelConfigCmd = pkgs.callPackage ./kernel-config-cmd.nix {
    inherit
      arch
      defconfig
      defconfigs
      additionalKernelConfig
      kernelSU
      susfs
      bbg
      finalMakeFlags
      ;
  };
in
stdenv.mkDerivation {
  name = "gcc-kernel";
  inherit src;

  nativeBuildInputs = [
    bc
    bc
    bison
    coreutils
    cpio
    elfutils
    flex
    gmp
    kmod
    libmpc
    mpfr
    nettools
    openssl
    pahole
    perl
    python3
    rsync
    ubootTools
    which
    zlib
    zstd

    gcc-aarch64-linux-android
    gcc-arm-linux-androideabi
  ];

  buildPhase = ''
    runHook preBuild

    ${kernelConfigCmd}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    make -j$(nproc) ${builtins.concatStringsSep " " finalMakeFlags}

    runHook postInstall
  '';

  dontFixup = true;
}
