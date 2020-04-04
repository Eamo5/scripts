#!/bin/bash
## Wahoo Kernel Build Script by @Eamo5
# Syntax - ./makewahoo.sh (branch) (gcc-version) (clean) (date)
# eg. ./makewahoo.sh sultan-r gcc-9.3 clean dd-mm-yy
# If no parameters are passed, the script defaults to the current branch with GCC 9.3

## Variables
KERNEL_DIR="$HOME"/kernels/builds/wahoo/
TOOLCHAIN_DIR="$HOME"/kernels/toolchains/
SULTAN_ZIP="$HOME"/zip-wahoo-sultan/
SULTAN_R_ZIP="$HOME"/zip-wahoo-sultan-r/
SULTAN_UNIFIED_ZIP="$HOME"/zip-wahoo-sultan-unified/
ZIP_OUTPUT_DIR="$HOME"/output/zips/
if  [ "$3" == "clean" ]; then
	VERSION_DATE=$4
else
	VERSION_DATE=$3
fi

## Kernel Directory
cd $KERNEL_DIR

## Build environment
set -e
export ARCH=arm64 SUBARCH=arm64 KBUILD_BUILD_USER=Eamo5 KBUILD_BUILD_HOST=HotBox

# Check for specified GCC parameters. If no valid argument passed, use GCC 9.3 by default.
case $2 in
	gcc-9.3)
		# Arch Linux Packages (aarch64-linux-gnu-gcc & arm-none-eabi-gcc)
		export CROSS_COMPILE="ccache aarch64-linux-gnu-" CROSS_COMPILE_ARM32="ccache arm-none-eabi-" ;;
	gcc-8)
		# https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/8.1.0/
		export CROSS_COMPILE="ccache ${TOOLCHAIN_DIR}aarch64-linux-8.1.0/bin/aarch64-linux-" CROSS_COMPILE_ARM32="ccache ${TOOLCHAIN_DIR}arm-linux-gnueabi-8.1.0/bin/arm-linux-gnueabi-" ;;
	*)
		echo "No valid toolchain selected... using GCC 9.3"
		export CROSS_COMPILE="ccache aarch64-linux-gnu-" CROSS_COMPILE_ARM32="ccache arm-none-eabi-" ;;
esac

## Checkout
git checkout "$1"
if  [ "$3" == "clean" ] || [ "$4" == "clean" ]; then
	git reset --hard
fi

## Prebuild Summary
echo ""
echo "Summary:"
echo ""
echo "Building = "$1""
echo "Date / Version = "$VERSION_DATE""
echo "Toolchain = "$2""
if [ "$3" == "clean" ] || [ "$4" == "clean" ]; then
	echo "Source = Clean"
else
	echo "Source = Dirty"
fi
echo ""

## Make
make -j$(nproc) clean
make -j$(nproc) mrproper
make -j$(nproc) O=out clean
make -j$(nproc) O=out mrproper
if [ "$1" == "sultan" ] || [ "$1" == "sultan-r" ] || [ "$1" == "sultan-qr-unified" ]; then
	make -j$(nproc) O=out wahoo_defconfig
else
	echo "Please run make -j$(nproc) <defconfig> first!"
	echo "Trying to build anyway..."
fi
	make -j$(nproc) O=out


## AnyKernel3
case $1 in
	sultan)
		cp ${KERNEL_DIR}out/arch/arm64/boot/Image.lz4-dtb ${SULTAN_ZIP}Image.lz4-dtb
		cp ${KERNEL_DIR}out/arch/arm64/boot/dtbo.img ${SULTAN_ZIP}dtbo.img ;;
	sultan-r)
		cp ${KERNEL_DIR}out/arch/arm64/boot/Image.lz4-dtb ${SULTAN_R_ZIP}Image.lz4-dtb
		cp ${KERNEL_DIR}out/arch/arm64/boot/dtbo.img ${SULTAN_R_ZIP}dtbo.img ;;
	sultan-qr-unified)
		cp ${KERNEL_DIR}out/arch/arm64/boot/Image.lz4-dtb ${SULTAN_UNIFIED_ZIP}Image.lz4-dtb
		cp ${KERNEL_DIR}out/arch/arm64/boot/dtbo.img ${SULTAN_UNIFIED_ZIP}dtbo.img ;;
	*)
		echo "You're on your own for zipping.."
		exit ;;
esac

## Zip
case $1 in
	sultan)
		cd ${SULTAN_ZIP}
		rm *.zip
		zip -r Sultan-Kernel-"$VERSION_DATE".zip * ;;
	sultan-r)
		cd ${SULTAN_R_ZIP}
		rm *.zip
		zip -r Sultan-Kernel-R-"$VERSION_DATE".zip * ;;
	sultan-qr-unified)
		cd ${SULTAN_UNIFIED_ZIP}
		rm *.zip
		zip -r Sultan-Kernel-+-"$VERSION_DATE".zip * ;;
esac 

## Output
case $1 in
	sultan)
		cp ${SULTAN_ZIP}Sultan-Kernel-"$VERSION_DATE".zip ${ZIP_OUTPUT_DIR}Sultan-Kernel-"$VERSION_DATE".zip
		echo "Done" ;;
	sultan-r)
		cp ${SULTAN_R_ZIP}Sultan-Kernel-R-"$VERSION_DATE".zip ${ZIP_OUTPUT_DIR}Sultan-Kernel-R-"$VERSION_DATE".zip
		echo "Done" ;;
	sultan-qr-unified)
		cp ${SULTAN_UNIFIED_ZIP}Sultan-Kernel-+-"$VERSION_DATE".zip ${ZIP_OUTPUT_DIR}Sultan-Kernel-+-"$VERSION_DATE".zip
		echo "Done" ;;
esac
