LOCAL_PATH := $(call my-dir)

ifneq (,$(filter $(word 2,$(subst -, ,$(LINUX_KERNEL_VERSION))),$(subst /, ,$(LOCAL_PATH))))

include $(CLEAR_VARS)
LOCAL_MODULE := fpsgo.ko

include $(MTK_KERNEL_MODULE)

endif # Kernel version matches current path
