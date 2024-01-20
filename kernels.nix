{
  callPackage,
  sources,
  ...
}: let
  pipeline = callPackage ./pipeline {};
in {
  amazon-fire-hd-karnak = pipeline {
    kernelDefconfigs = ["lineageos_karnak_defconfig"];
    kernelImageName = "Image.gz-dtb";
    kernelMakeFlags = [
      "KCFLAGS=\"-w\""
      "KCPPFLAGS=\"-w\""
    ];
    kernelSrc = sources.linux-amazon-karnak.src;
    oemBootImg = boot/amazon-fire-hd-karnak.img;
  };

  moto-rtwo-lineageos-21 = pipeline {
    clangVersion = "latest";
    kernelDefconfigs = [
      "gki_defconfig"
      "vendor/kalama_GKI.config"
      "vendor/ext_config/moto-kalama.config"
      "vendor/ext_config/moto-kalama-gki.config"
      "vendor/ext_config/moto-kalama-rtwo.config"
    ];
    kernelImageName = "Image";
    kernelSrc = sources.linux-moto-rtwo-lineageos-21.src;
  };

  oneplus-8t-blu-spark = pipeline {
    clangVersion = "latest";
    kernelDefconfigs = ["blu_spark_defconfig"];
    kernelImageName = "Image";
    kernelSrc = sources.linux-oneplus-8t-blu-spark.src;
  };
}
