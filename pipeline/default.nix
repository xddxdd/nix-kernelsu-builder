{
  lib,
  callPackage,
  # User args
  arch ? "arm64",
  kernelDefconfigs ? [],
  kernelImageName ? "Image",
  kernelPatches ? [],
  kernelSrc,
  oemBootImg ? null,
  ...
}: let
  patchedKernelSrc = callPackage ./patch-kernel-src.nix {
    src = kernelSrc;
    patches = kernelPatches;
  };

  kernelBuildGcc = callPackage ./build-kernel-gcc.nix {
    inherit arch;
    src = patchedKernelSrc;
    defconfigs = kernelDefconfigs;
  };

  # TODO: switch between GCC and CLANG
  kernelBuild = kernelBuildGcc;

  bootImg = callPackage ./build-boot-img.nix {
    inherit arch kernelImageName;
    bootImg = oemBootImg;
    kernel = kernelBuild;
  };
in
  bootImg
