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

  # nixpkgs' clang cc-wrapper (add-clang-cc-cflags-before.sh) injects the host
  # machineFlags into `extraBefore` whenever `NIX_CC_WRAPPER_SUPPRESS_TARGET_WARNING`
  # is set, even when the caller passes an explicit `--target`. On x86_64 hosts
  # with clang >= 19 this includes `-mtls-dialect=gnu2`, which clang rejects for
  # the aarch64 cross target the kernel build uses (CLANG_TRIPLE=aarch64-linux-gnu-),
  # breaking the whole kernel build with:
  #   clang: error: unsupported option '-mtls-dialect=' for target 'aarch64-...'
  # Patch the wrapper so machineFlags are only added when no `--target` is passed,
  # which is the intended behavior. Using `--replace` (not `--replace-fail`) keeps
  # this forward-compatible if upstream restructures the script.
  fixedCC = usedLLVMPackages.stdenv.cc.overrideAttrs (
    final: prev: {
      postFixup = (prev.postFixup or "") + ''
        substituteInPlace $out/nix-support/add-local-cc-cflags-before.sh \
          --replace 'elif [[ $0 != *cpp ]]; then' 'elif ! $targetPassed && [[ $0 != *cpp ]]; then'
      '';
    }
  );
  fixedStdenv = pkgs.stdenvAdapters.overrideCC usedLLVMPackages.stdenv fixedCC;
in
fixedStdenv.mkDerivation {
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
