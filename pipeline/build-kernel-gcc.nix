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
  enableKernelSU,
  makeFlags,
  ...
}: let
  gcc-aarch64-linux-android = pkgs.callPackage ../pkgs/gcc-aarch64-linux-android.nix {};
  gcc-arm-linux-androideabi = pkgs.callPackage ../pkgs/gcc-arm-linux-androideabi.nix {};

  finalMakeFlags =
    [
      "-j$(nproc --all)"
      "ARCH=${arch}"
      "CROSS_COMPILE=aarch64-linux-android-"
      "CROSS_COMPILE_ARM32=arm-linux-androideabi-"
      "O=$out"
    ]
    ++ makeFlags;

  defconfig = lib.last defconfigs;
in
  stdenv.mkDerivation {
    name = "gcc-kernel";
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

      gcc-aarch64-linux-android
      gcc-arm-linux-androideabi
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
