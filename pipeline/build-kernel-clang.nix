{
  pkgs,
  lib,
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
  clangVersion,
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
  finalMakeFlags = [
    "ARCH=${arch}"
    "CC=clang"
    "O=$out"
    "LD=ld.lld"
    "LLVM=1"
    "LLVM_IAS=1"
    "CLANG_TRIPLE=aarch64-linux-gnu-"
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

  usedLLVMPackages = pkgs."llvmPackages_${builtins.toString clangVersion}";
in
usedLLVMPackages.stdenv.mkDerivation {
  name = "clang-kernel-${builtins.toString clangVersion}";
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

    usedLLVMPackages.bintools
  ];

  env.NIX_CC_WRAPPER_SUPPRESS_TARGET_WARNING = "1";

  hardeningDisable = [ "all" ];

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
