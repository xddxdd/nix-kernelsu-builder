_: {
  perSystem =
    { pkgs, ... }:
    let
      sources = pkgs.callPackage _sources/generated.nix { };
    in
    {
      kernelsu = {
        amazon-fire-hd-karnak = {
          anyKernelVariant = "osm0sis";
          enableKernelSU = false;
          kernelDefconfigs = [ "lineageos_karnak_defconfig" ];
          kernelImageName = "Image.gz-dtb";
          kernelMakeFlags = [
            "KCFLAGS=\"-w\""
            "KCPPFLAGS=\"-w\""
          ];
          kernelSrc = sources.linux-amazon-karnak.src;
          oemBootImg = boot/amazon-fire-hd-karnak.img;
        };

        moto-rtwo-lineageos-21 = {
          anyKernelVariant = "kernelsu";
          clangVersion = "latest";
          kernelDefconfigs = [
            "gki_defconfig"
            "vendor/kalama_GKI.config"
            "vendor/ext_config/moto-kalama.config"
            "vendor/ext_config/moto-kalama-gki.config"
            "vendor/ext_config/moto-kalama-rtwo.config"
          ];
          kernelImageName = "Image";
          kernelMakeFlags = [
            "KCFLAGS=\"-w\""
            "KCPPFLAGS=\"-w\""
          ];
          kernelSrc = sources.linux-moto-rtwo-lineageos-21.src;
        };

        oneplus-8t-blu-spark = {
          anyKernelVariant = "osm0sis";
          clangVersion = "latest";
          kernelDefconfigs = [ "blu_spark_defconfig" ];
          kernelImageName = "Image";
          kernelSrc = sources.linux-oneplus-8t-blu-spark.src;
          kernelConfig = ''
            CONFIG_STACKPROTECTOR=n
            CONFIG_LTO_CLANG=y
          '';
        };
      };
    };
}
