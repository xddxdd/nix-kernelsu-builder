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

        # BROKEN FOR NOW
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
          clangVersion = "18";
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
          # https://github.com/HanKuCha/oneplus13_a5p_sukisu/blob/main/.github/workflows/oneplus_13.yml
          # https://github.com/aisessss/build_oneplus_sm8750/blob/main/Build_sm8750.sh
          kernelConfig = ''
            CONFIG_KSU=y
            CONFIG_KSU_SUSFS_SUS_SU=n
            CONFIG_KSU_MANUAL_HOOK=y
            CONFIG_KSU_SUSFS=y
            CONFIG_KSU_SUSFS_HAS_MAGIC_MOUNT=y
            CONFIG_KSU_SUSFS_SUS_PATH=y
            CONFIG_KSU_SUSFS_SUS_MOUNT=y
            CONFIG_KSU_SUSFS_AUTO_ADD_SUS_KSU_DEFAULT_MOUNT=y
            CONFIG_KSU_SUSFS_AUTO_ADD_SUS_BIND_MOUNT=y
            CONFIG_KSU_SUSFS_SUS_KSTAT=y
            CONFIG_KSU_SUSFS_TRY_UMOUNT=y
            CONFIG_KSU_SUSFS_AUTO_ADD_TRY_UMOUNT_FOR_BIND_MOUNT=y
            CONFIG_KSU_SUSFS_SPOOF_UNAME=y
            CONFIG_KSU_SUSFS_ENABLE_LOG=y
            CONFIG_KSU_SUSFS_HIDE_KSU_SUSFS_SYMBOLS=y
            CONFIG_KSU_SUSFS_SPOOF_CMDLINE_OR_BOOTCONFIG=y
            CONFIG_KSU_SUSFS_OPEN_REDIRECT=y

            # 启用高级压缩支持
            CONFIG_CRYPTO_LZ4HC=y
            CONFIG_CRYPTO_LZ4=y
            CONFIG_CRYPTO_ZSTD=y

            # 文件系统级压缩支持
            CONFIG_F2FS_FS_COMPRESSION=y
            CONFIG_F2FS_FS_LZ4=y
            CONFIG_F2FS_FS_LZ4HC=y
            CONFIG_F2FS_FS_ZSTD=y

            # 内核镜像压缩配置
            CONFIG_KERNEL_LZ4=y

            # BBR(TCP拥塞控制算法)
            CONFIG_TCP_CONG_ADVANCED=y
            CONFIG_TCP_CONG_BBR=y
            CONFIG_NET_SCH_FQ=y
            CONFIG_TCP_CONG_BIC=n
            CONFIG_TCP_CONG_CUBIC=n
            CONFIG_TCP_CONG_WESTWOOD=n
            CONFIG_TCP_CONG_HTCP=n
            CONFIG_DEFAULT_TCP_CONG=bbr

            CONFIG_LOCALVERSION_AUTO=n
          '';
          kernelDefconfigs = [ "gki_defconfig" ];
          kernelImageName = "Image";
          kernelMakeFlags = [
            "KCFLAGS=\"-w\""
            "KCPPFLAGS=\"-w\""
          ];
          kernelPatches = [
            "${sources.sukisu-patch.src}/69_hide_stuff.patch"
          ];
          kernelSrc = sources.linux-oneplus-13.src;

          postPatch = ''
            # https://github.com/HanKuCha/oneplus13_a5p_sukisu/blob/1604ce2607a04c4d9b8f1ba426a601bedac6d989/.github/workflows/oneplus_ace5_pro.yml#L122-L201
            install -Dm644 ${./resources/oneplus-13-hmbird-patch.c} drivers/hmbird_patch.c
            echo "obj-y += hmbird_patch.o" >> drivers/Makefile

            # https://github.com/HanKuCha/oneplus13_a5p_sukisu/blob/1604ce2607a04c4d9b8f1ba426a601bedac6d989/.github/workflows/oneplus_13.yml#L264-L271
            cp -r ${sources.oneplus-13-sched-ext.src}/* kernel/sched/

            substituteInPlace build.config.gki \
              --replace-fail "check_defconfig" ""
            substituteInPlace scripts/setlocalversion \
              --replace-fail '${"\${scm_version}"}' ""
            substituteInPlace arch/arm64/configs/gki_defconfig \
              --replace-fail "-4k" "-android15-8-g013ec21bba94-abogki383916444-4k"

            chmod -R +w .
          '';
        };
      };
    };
}
