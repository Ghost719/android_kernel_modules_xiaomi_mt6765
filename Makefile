
ARCH ?= arm
KERNEL ?= $(abspath ..)
KERNEL_CONFIG ?= cactus_defconfig
KERNEL_MODULES ?= $(KERNEL)/modules
KERNEL_VERSION ?= 4.9

CROSS_COMPILE ?= $(HOME)/xiaomi-mt6765/gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-
OUT = $(KERNEL)/out

# variants: mt66xx  mt76xx
BT_VER ?= mt66xx

# variants: gen2  gen3  gen4  gen4m  gen4-mt7668
WLAN_VER ?= gen4m

# do not touch
CONNECTIVITY = $(KERNEL_MODULES)/connectivity
FPSGO = $(KERNEL_MODULES)/fpsgo_cus/$(KERNEL_VERSION)
MET_DRV = $(KERNEL_MODULES)/met_drv/$(KERNEL_VERSION)

AUTOCONF_H = $(OUT)/include/generated/autoconf.h
WMT_SRC_FOLDER = $(CONNECTIVITY)/common

export AUTOCONF_H WMT_SRC_FOLDER
export CONNECTIVITY FPSGO MET_DRV

export ARCH KERNEL KERNEL_CONFIG KERNEL_MODULES KERNEL_VERSION
export CROSS_COMPILE OUT

# for gen4m options
export CONFIG_MTK_COMBO_WIFI_HIF=axi
export MTK_COMBO_CHIP=CONNAC
export WLAN_CHIP_ID=6765
export MTK_ANDROID_WMT=y

# for gps
export CONFIG_MTK_COMBO_CHIP=CONSYS_6765

all: build

build:
	# fpsgo_cus
	ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C $(OUT)/ O=$(OUT) M=$(FPSGO) modules

	# connectivity common
	ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C $(OUT)/ O=$(OUT) M=$(CONNECTIVITY)/common modules

	# connectivity
	ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C $(OUT)/ O=$(OUT) M=$(CONNECTIVITY)/bt/$(BT_VER) modules
	ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C $(OUT)/ O=$(OUT) M=$(CONNECTIVITY)/fmradio modules
	ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C $(OUT)/ O=$(OUT) M=$(CONNECTIVITY)/gps modules
	ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C $(OUT)/ O=$(OUT) M=$(CONNECTIVITY)/wlan/adaptor modules
	ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C $(OUT)/ O=$(OUT) M=$(CONNECTIVITY)/wlan/core/$(WLAN_VER) modules

	# met_drv
	ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C $(OUT)/ O=$(OUT) M=$(MET_DRV) modules

clean:
	# fpsgo_cus
	#ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C $(OUT)/ O=$(OUT) M=$(FPSGO) clean
	-rm -rf $(FPSGO)/.tmp_versions
	-rm -f $(FPSGO)/*.mod.o
	-rm -f $(FPSGO)/*.mod.c
	-rm -f $(FPSGO)/.*.cmd
	-rm -f $(FPSGO)/*.cmd
	-rm -f $(FPSGO)/*.ko
	-rm -f $(FPSGO)/modules.order
	-rm -f $(FPSGO)/Module.symvers
	-rm -f $(FPSGO)/src/fpsgo.o
	-rm -f $(FPSGO)/src/fpsgo_main.o
	-rm -f $(FPSGO)/src/.fpsgo_main.o.cmd

	# connectivity common
	ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C $(OUT)/ O=$(OUT) M=$(CONNECTIVITY)/common clean

	# connectivity
	ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C $(OUT)/ O=$(OUT) M=$(CONNECTIVITY)/bt/$(BT_VER) clean
	ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C $(OUT)/ O=$(OUT) M=$(CONNECTIVITY)/fmradio clean
	ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C $(OUT)/ O=$(OUT) M=$(CONNECTIVITY)/gps clean
	ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C $(OUT)/ O=$(OUT) M=$(CONNECTIVITY)/wlan/adaptor clean
	ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C $(OUT)/ O=$(OUT) M=$(CONNECTIVITY)/wlan/core/$(WLAN_VER) clean

	# met_drv
	ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C $(OUT)/ O=$(OUT) M=$(MET_DRV) clean

	-rm -rf build/

pack:
	mkdir -p build/
	-find -name "*.ko" -exec cp {} build/ \;
	$(CROSS_COMPILE)strip --strip-unneeded build/*.ko

prepare:
	ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C $(KERNEL)/ O=$(OUT) $(KERNEL_CONFIG)
	ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C $(KERNEL)/ O=$(OUT) modules_prepare

kernel_clean:
	ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C $(KERNEL)/ O=$(OUT) mrproper
	ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C $(KERNEL)/ O=$(OUT) clean
