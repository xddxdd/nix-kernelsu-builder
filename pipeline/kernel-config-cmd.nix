{
  lib,
  # Options
  arch,
  defconfig,
  defconfigs,
  additionalKernelConfig,
  kernelSU,
  susfs,
  finalMakeFlags,
}:
''
  export CFG_PATH=arch/${arch}/configs/${defconfig}
  cat >>$CFG_PATH <<EOF
  ${additionalKernelConfig}
  EOF
''
+ (lib.optionalString kernelSU.enable ''
  # Inject KernelSU options
  echo "CONFIG_MODULES=y" >> $CFG_PATH
  echo "CONFIG_KPROBES=y" >> $CFG_PATH
  echo "CONFIG_HAVE_KPROBES=y" >> $CFG_PATH
  echo "CONFIG_KPROBE_EVENTS=y" >> $CFG_PATH
  echo "CONFIG_OVERLAY_FS=y" >> $CFG_PATH
  echo "CONFIG_KSU=y" >> $CFG_PATH
'')
+ (lib.optionalString susfs.enable ''
  echo "CONFIG_KSU_SUSFS=y" >> $CFG_PATH
  echo "CONFIG_KSU_SUSFS_HAS_MAGIC_MOUNT=y" >> $CFG_PATH
  echo "CONFIG_KSU_SUSFS_SUS_PATH=y" >> $CFG_PATH
  echo "CONFIG_KSU_SUSFS_SUS_MOUNT=y" >> $CFG_PATH
  echo "CONFIG_KSU_SUSFS_AUTO_ADD_SUS_KSU_DEFAULT_MOUNT=y" >> $CFG_PATH
  echo "CONFIG_KSU_SUSFS_AUTO_ADD_SUS_BIND_MOUNT=y" >> $CFG_PATH
  echo "CONFIG_KSU_SUSFS_SUS_KSTAT=y" >> $CFG_PATH
  echo "CONFIG_KSU_SUSFS_SUS_OVERLAYFS=y" >> $CFG_PATH
  echo "CONFIG_KSU_SUSFS_TRY_UMOUNT=y" >> $CFG_PATH
  echo "CONFIG_KSU_SUSFS_AUTO_ADD_TRY_UMOUNT_FOR_BIND_MOUNT=y" >> $CFG_PATH
  echo "CONFIG_KSU_SUSFS_SPOOF_UNAME=y" >> $CFG_PATH
  echo "CONFIG_KSU_SUSFS_ENABLE_LOG=y" >> $CFG_PATH
  echo "CONFIG_KSU_SUSFS_HIDE_KSU_SUSFS_SYMBOLS=y" >> $CFG_PATH
  echo "CONFIG_KSU_SUSFS_SPOOF_CMDLINE_OR_BOOTCONFIG=y" >> $CFG_PATH
  echo "CONFIG_KSU_SUSFS_OPEN_REDIRECT=y" >> $CFG_PATH
  echo "CONFIG_KSU_SUSFS_SUS_SU=y" >> $CFG_PATH
  echo "CONFIG_TMPFS_XATTR=y" >> $CFG_PATH
'')
+ ''
  mkdir -p $out
  make ${builtins.concatStringsSep " " (finalMakeFlags ++ defconfigs)}
''
