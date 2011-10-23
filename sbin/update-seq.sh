#!/bin/sh

fail() {
	echo "Failed"
	echo "$1"
	cleanup
	exit 0
}

cleanup() {
echo "" > /sys/devices/platform/usb_mass_storage/lun0/file
LIST=`mount | grep "^/" | grep "type yaffs*\|vfat\|ext*" | grep "system*\|data\|sdcard*" | cut -d\  -f 3 | sort -rn`
if [ "$LIST" != "" ]; then
	for i in $LIST
	do
		echo "unmounting $i"		
		umount $i
			if [ $? != "0" ]; then
				echo "Unable to unmount $i !"
				exit 1
			fi
	done
fi
}

echo "Installing...update"
if [ -f /sdcard/update.tgz ] ; then
	tar -xzf /sdcard/update.tgz -C /
	[ $? -eq 0 ] || fail "Can't extract update"
	echo "Android Update Installed"
else
	echo "Error updating android."
fi
cleanup
