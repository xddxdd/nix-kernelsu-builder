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
''
+ (lib.optionalString kernelSU.enable ''
  CONFIG_MODULES=y
  CONFIG_KPROBES=y
  CONFIG_HAVE_KPROBES=y
  CONFIG_KPROBE_EVENTS=y
  CONFIG_OVERLAY_FS=y
  CONFIG_KSU=y
'')
+ (lib.optionalString susfs.enable ''
  CONFIG_KSU_SUSFS=y
  CONFIG_KSU_SUSFS_HAS_MAGIC_MOUNT=y
  CONFIG_KSU_SUSFS_SUS_PATH=y
  CONFIG_KSU_SUSFS_SUS_MOUNT=y
  CONFIG_KSU_SUSFS_AUTO_ADD_SUS_KSU_DEFAULT_MOUNT=y
  CONFIG_KSU_SUSFS_AUTO_ADD_SUS_BIND_MOUNT=y
  CONFIG_KSU_SUSFS_SUS_KSTAT=y
  CONFIG_KSU_SUSFS_SUS_OVERLAYFS=y
  CONFIG_KSU_SUSFS_TRY_UMOUNT=y
  CONFIG_KSU_SUSFS_AUTO_ADD_TRY_UMOUNT_FOR_BIND_MOUNT=y
  CONFIG_KSU_SUSFS_SPOOF_UNAME=y
  CONFIG_KSU_SUSFS_ENABLE_LOG=y
  CONFIG_KSU_SUSFS_HIDE_KSU_SUSFS_SYMBOLS=y
  CONFIG_KSU_SUSFS_SPOOF_CMDLINE_OR_BOOTCONFIG=y
  CONFIG_KSU_SUSFS_OPEN_REDIRECT=y
  CONFIG_KSU_SUSFS_SUS_SU=y
  CONFIG_TMPFS_XATTR=y
  CONFIG_TMPFS_POSIX_ACL=y
'')
+ ''
  ${additionalKernelConfig}
  EOF
  mkdir -p $out
  make ${builtins.concatStringsSep " " (finalMakeFlags ++ defconfigs)}
''
