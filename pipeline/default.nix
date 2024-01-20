{
  lib,
  callPackage,
  runCommand,
  # User args
  arch ? "arm64",
  enableKernelSU ? true,
  kernelDefconfigs ? [],
  kernelImageName ? "Image",
  kernelMakeFlags ? [],
  kernelPatches ? [],
  kernelSrc,
  oemBootImg ? null,
  ...
}: let
  patchedKernelSrc = callPackage ./patch-kernel-src.nix {
    inherit enableKernelSU;
    src = kernelSrc;
    patches = kernelPatches;
  };

  kernelBuildGcc = callPackage ./build-kernel-gcc.nix {
    inherit arch;
    src = patchedKernelSrc;
    defconfigs = kernelDefconfigs;
    makeFlags = kernelMakeFlags;
  };

  # TODO: switch between GCC and CLANG
  kernelBuild = kernelBuildGcc;

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
