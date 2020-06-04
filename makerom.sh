#!/bin/bash
# ./makerom.sh <rom> <device> <optional sync> <optional discard>
# eg. ./makerom.sh lineage17 taimen sync

## Variables
ROM_DIR=""$HOME"/roms/"$1""

## Environment
set -e
cd "$ROM_DIR"
source "$ROM_DIR/build/envsetup.sh"

# when signing builds, /tmp being too small can be problematic
sudo mount -o remount,size=15G /tmp

## Sync
if [ "$3" == "sync" ] && [ "$4" == "" ]; then
	repo sync -c --force-sync --no-clone-bundle --no-tags -j8
elif [ "$3" == "sync" ] && [ "$4" == "discard" ]; then
        repo sync -c -d --force-sync --no-clone-bundle --no-tags -j8
fi

## Build
echo "Starting build..."
case "$1" in
	lineage17)
		breakfast lineage_"$2"-userdebug
		m installclean
		brunch lineage_"$2"-userdebug ;;
	aosip)
		lunch aosip_"$2"-user
		m installclean
		m kronic ;;
	aicp)
		breakfast aicp_"$2"-userdebug
		m installclean
		brunch aicp_"$2"-userdebug ;;
esac

## Build Signing
if [ "$1" == "lineage17" ]; then
	m target-files-package otatools

	# Sign APKs
	echo "Signing APKs..."
	./build/tools/releasetools/sign_target_files_apks -o -d "$HOME"/.android-certs \
	    $OUT/obj/PACKAGING/target_files_intermediates/*-target_files-*.zip \
	    signed-target_files.zip

	# Generate Install Package
	./build/tools/releasetools/ota_from_target_files -k "$HOME"/.android-certs/releasekey \
	    --block \
	    signed-target_files.zip \
	    signed-ota_update.zip
fi

echo "Done!"
