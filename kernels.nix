{
  callPackage,
  sources,
  ...
}: {
  amazon-fire-hd-karnak = callPackage ./pipeline {
    kernelDefconfigs = ["lineageos_karnak_defconfig"];
    kernelImageName = "Image.gz-dtb";
    kernelSrc = sources.linux-amazon-karnak.src;
    kernelPatches = [];
    oemBootImg = boot/amazon-fire-hd-karnak.img;
  };
}
