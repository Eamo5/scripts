#!/bin/bash
# ./makerom.sh <rom> <device> <optional sync> <optional pick> <optional upload>
# eg. ./makerom.sh lineage18 taimen sync

## Variables
if [ -e "$HOME"/roms/"$1" ]; then
	ROM_DIR=""$HOME"/roms/"$1""
else
	echo "Unable to find rom directory. YOLO try and build anyway."
	ROM_DIR="$pwd"
fi

case "$2" in
	coral)
		PARENT=13htD7BIUPErNCbq8KUZsZVdWho5MMk0x ;;
	flame)
		PARENT=1JJbsXJLw_3A5AL_AxC0Q4nty3lFmZyan ;;
	taimen)
		PARENT=1bt9WnzQ4LZlgzRgUaEAqaXJfEvNj2Nug ;;
	walleye)
		PARENT=1gCPZ289x_kgsvp2WJyXacRNY7hCg3r8J ;;
esac

## Environment
set -e
cd "$ROM_DIR"
source "$ROM_DIR/build/envsetup.sh"

## Sync
if [ "$3" == "sync" ] || [ "$4" == "sync" ] || [ "$5" == "sync" ]; then
	repo sync -c --force-sync --no-clone-bundle --no-tags -j8 -d
fi

if [ "$3" == "patch" ] || [ "$4" == "patch" ] || [ "$5" == "patch" ]; then
	bash "$ROM_DIR"/patch.sh
fi

## Build
echo "Starting build..."
case "$1" in
	lineage18 | lineage17)
		breakfast lineage_"$2"-userdebug
		m installclean
		brunch lineage_"$2"-userdebug ;;
	*)
		breakfast "$1"_"$2"-userdebug
		m installclean
		brunch "$1"_"$2"-userdebug ;;
esac

if [ "$3" == "upload" ] || [ "$4" == "upload" ] || [ "$5" == "upload" ] && [ "$1" == "lineage18" ]; then
	gdrive upload -p "$PARENT" "$OUT"/lineage-18.1-*.zip
	if [ "$2" == "coral" ] || [ "$2" == "flame" ]; then
		gdrive upload -p "$PARENT" "$OUT"/boot.img
	fi
fi

echo "Done!"
