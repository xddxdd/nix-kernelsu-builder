{
  lib,
  callPackage,
  runCommand,
  ...
}: {
  arch ? "arm64",
  clangVersion ? null,
  enableKernelSU ? true,
  kernelDefconfigs ? [],
  kernelImageName ? "Image",
  kernelMakeFlags ? [],
  kernelPatches ? [],
  kernelSrc,
  oemBootImg ? null,
}: let
  patchedKernelSrc = callPackage ./patch-kernel-src.nix {
    inherit enableKernelSU;
    src = kernelSrc;
    patches = kernelPatches;
  };

  kernelBuildClang = callPackage ./build-kernel-clang.nix {
    inherit arch clangVersion enableKernelSU;
    src = patchedKernelSrc;
    defconfigs = kernelDefconfigs;
    makeFlags = kernelMakeFlags;
  };

  kernelBuildGcc = callPackage ./build-kernel-gcc.nix {
    inherit arch enableKernelSU;
    src = patchedKernelSrc;
    defconfigs = kernelDefconfigs;
    makeFlags = kernelMakeFlags;
  };

  kernelBuild =
    if clangVersion == null
    then kernelBuildGcc
    else kernelBuildClang;

  anykernelZip = callPackage ./build-anykernel-zip.nix {
    inherit arch kernelImageName;
    kernel = kernelBuild;
  };

  bootImg = callPackage ./build-boot-img.nix {
    inherit arch kernelImageName;
    bootImg = oemBootImg;
    kernel = kernelBuild;
  };
in
  runCommand "kernel-bundle" {} (''
      mkdir -p $out
      cp ${kernelBuild}/arch/${arch}/boot/${kernelImageName} $out/
        if [ -f ${kernelBuild}/arch/${arch}/boot/dtbo.img ]; then
          cp ${kernelBuild}/arch/${arch}/boot/dtbo.img $out/
        fi
      cp ${anykernelZip}/anykernel.zip $out/
    ''
    + (lib.optionalString (oemBootImg != null) ''
      cp ${bootImg}/boot.img $out/
    ''))
