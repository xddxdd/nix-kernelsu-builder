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
  enableKernelSU,
  makeFlags,
  ...
}: let
  finalMakeFlags =
    [
      "-j$(nproc --all)"
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

  usedLLVMPackages = pkgs."llvmPackages_${builtins.toString clangVersion}";
in
  usedLLVMPackages.stdenv.mkDerivation {
    name = "clang-kernel-${builtins.toString clangVersion}";
    src = src;

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

    buildPhase =
      ''
        runHook preBuild
      ''
      + (lib.optionalString enableKernelSU ''
        # Inject KernelSU options
        export CFG_PATH=arch/${arch}/configs/${defconfig}
        echo "CONFIG_MODULES=y" >> $CFG_PATH
        echo "CONFIG_KPROBES=y" >> $CFG_PATH
        echo "CONFIG_HAVE_KPROBES=y" >> $CFG_PATH
        echo "CONFIG_KPROBE_EVENTS=y" >> $CFG_PATH
        echo "CONFIG_OVERLAY_FS=y" >> $CFG_PATH
      '')
      + ''
        mkdir -p $out
        make ${builtins.concatStringsSep " " (finalMakeFlags ++ defconfigs)}

        runHook postBuild
      '';

    installPhase = ''
      runHook preInstall

      make ${builtins.concatStringsSep " " finalMakeFlags}

      runHook postInstall
    '';

    dontFixup = true;
  }
