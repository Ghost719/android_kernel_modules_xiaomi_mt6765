# MTK Kernel Modules for MT6765

# Prepare
	cd android_kernel_xiaomi_mt6765/
	git clone https://github.com/Ghost719/android_kernel_modules_xiaomi_mt6765 -b kernel modules/
	export KERNEL=$PWD
	cd modules/

# Compiling
Look at the top of `Makefile` to configure.
	export ARCH=arm
	export CROSS_COMPILE=$HOME/gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-
	make
	make pack
	ls build/*
