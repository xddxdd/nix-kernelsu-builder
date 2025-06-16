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
          kernelSU.enable = false;
          kernelDefconfigs = [ "lineageos_karnak_defconfig" ];
          kernelImageName = "Image.gz-dtb";
          kernelMakeFlags = [
            "KCFLAGS=\"-w\""
            "KCPPFLAGS=\"-w\""
          ];
          kernelSrc = sources.linux-amazon-karnak.src;
          oemBootImg = resources/amazon-fire-hd-karnak-boot.img;
        };

        moto-rtwo-lineageos-21 = {
          anyKernelVariant = "kernelsu";
          clangVersion = "latest";

          kernelSU.variant = "sukisu-susfs";
          susfs = {
            enable = true;
            inherit (sources.susfs-android13-5_15) src;
          };

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
          kernelPatches = [
            "${sources.wildplus-kernel-patches.src}/69_hide_stuff.patch"
          ];
          kernelSrc = sources.linux-moto-rtwo-lineageos-21.src;
        };

        moto-rtwo-lineageos-22_1 = {
          anyKernelVariant = "kernelsu";
          clangVersion = "latest";

          kernelSU.variant = "sukisu-susfs";
          susfs = {
            enable = true;
            inherit (sources.susfs-android13-5_15) src;
          };

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
          kernelPatches = [
            "${sources.wildplus-kernel-patches.src}/69_hide_stuff.patch"
          ];
          kernelSrc = sources.linux-moto-rtwo-lineageos-22_1.src;
        };

        oneplus-8t-blu-spark = {
          anyKernelVariant = "osm0sis";
          clangVersion = "latest";
          kernelSU.variant = "sukisu";
          kernelDefconfigs = [ "blu_spark_defconfig" ];
          kernelImageName = "Image";
          kernelMakeFlags = [
            "KCFLAGS=\"-w\""
            "KCPPFLAGS=\"-w\""
          ];
          kernelSrc = sources.linux-oneplus-8t-blu-spark.src;
        };

        # DOESN'T BOOT FOR NOW
        oneplus-13 = {
          anyKernelVariant = "kernelsu";
          clangVersion = "latest";
          kernelSU.variant = "sukisu-susfs";
          susfs = {
            enable = true;
            src = pkgs.stdenv.mkDerivation {
              inherit (sources.susfs-android15-6_6) pname version src;
              # https://github.com/HanKuCha/oneplus13_a5p_sukisu/blob/1604ce2607a04c4d9b8f1ba426a601bedac6d989/.github/workflows/oneplus_ace5_pro.yml#L114-L115
              patchPhase = ''
                sed -i 's/-32,12 +32,38/-32,11 +32,37/g' kernel_patches/50_add_susfs_in_gki-android15-6.6.patch
                sed -i '/#include <trace\/hooks\/fs.h>/d' kernel_patches/50_add_susfs_in_gki-android15-6.6.patch
              '';
              installPhase = ''
                mkdir -p $out
                cp -r * $out/
              '';
            };
          };
          kernelConfig = ''
            CONFIG_CRYPTO_842=y
            CONFIG_CRYPTO_LZ4HC=y
            CONFIG_CRYPTO_LZ4K=y
            CONFIG_CRYPTO_LZ4KD=y
            CONFIG_KSU_MANUAL_HOOK=y
            CONFIG_KSU_SUSFS_SUS_SU=n
          '';
          kernelDefconfigs = [ "gki_defconfig" ];
          kernelImageName = "Image";
          kernelMakeFlags = [
            "KCFLAGS=\"-w\""
            "KCPPFLAGS=\"-w\""
          ];
          kernelPatches = [
            "${sources.sukisu-patch.src}/69_hide_stuff.patch"
            "${sources.sukisu-patch.src}/hooks/syscall_hooks.patch"
          ];
          kernelSrc = sources.linux-oneplus-13.src;

          postPatch = ''
            # https://github.com/HanKuCha/oneplus13_a5p_sukisu/blob/1604ce2607a04c4d9b8f1ba426a601bedac6d989/.github/workflows/oneplus_ace5_pro.yml#L122-L201
            install -Dm644 ${./resources/oneplus-13-hmbird-patch.c} drivers/hmbird_patch.c
            echo "obj-y += hmbird_patch.o" >> drivers/Makefile

            # https://github.com/HanKuCha/oneplus13_a5p_sukisu/blob/1604ce2607a04c4d9b8f1ba426a601bedac6d989/.github/workflows/oneplus_13.yml#L105-L109
            cp -r ${sources.sukisu-patch.src}/other/zram/lz4k/include/linux/* include/linux/
            cp -r ${sources.sukisu-patch.src}/other/zram/lz4k/lib/* lib/
            cp -r ${sources.sukisu-patch.src}/other/zram/lz4k/crypto/* crypto/
            cp -r ${sources.sukisu-patch.src}/other/zram/lz4k_oplus lib/
            patch -p1 -F3 < ${sources.sukisu-patch.src}/other/zram/zram_patch/6.6/lz4kd.patch

            # https://github.com/HanKuCha/oneplus13_a5p_sukisu/blob/1604ce2607a04c4d9b8f1ba426a601bedac6d989/.github/workflows/oneplus_13.yml#L264-L271
            cp -r ${sources.oneplus-13-sched-ext.src}/* kernel/sched/

            chmod -R +w .
          '';
        };
      };
    };
}
