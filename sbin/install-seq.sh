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


if [ -f /sdcard/andboot/androidinstall.tgz ] ; then
	tar -xzf /sdcard/andboot/androidinstall.tgz -C /
	[ $? -eq 0 ] || fail "Failed to extract Androidinstall"
elif [ -f /sdcard/andboot/system.ext2 ] ; then
	losetup /dev/block/loop0 /sdcard/andboot/system.ext2
	mount -t ext2 /dev/block/loop0 /tmp
	cp -a /tmp/* /system
	umount /tmp
	losetup -d /dev/block/loop0
fi


echo "Installing...Updates"
if [ -f /sdcard/andboot/androidupdate.tgz ] ; then
	tar -xzf /sdcard/andboot/androidupdate.tgz -C /
	[ $? -eq 0 ] || fail "Failed to extract AndroidUpdate"
fi

#this is experimental
#echo 6 > /sys/module/yaffs/parameters/yaffs_auto_checkpoint
sync

	[ -f /system/etc/wifi/wlan.ko ] && rm /system/etc/wifi/wlan.ko

sed -i s/^#wifi/wifi/ /system/build.prop


if [ "`grep -c ^wifi /system/build.prop`" != "2" ]; then
	echo "wifi.interface = eth0" >> /system/build.prop
	echo "wifi.supplicant_scan_interval = 45" >> /system/build.prop
fi

# init.rc: fix wpa_supplicant service
sed -i s/-itiwlan0/-ieth0/ /system/sysinit.rc
sed -i s/-Dtiwlan0/-Dwext/ /system/sysinit.rc

# init.rc: fix dhcpcd service, wifi.interface, and wpa_supplicant service socket
sed -i s/tiwlan0/eth0/ /system/sysinit.rc

# init.rc:
sed -i s/user\ wifi/#user\ wifi/ /system/sysinit.rc
sed -i s/group\ wifi/#group\ wifi/ /system/sysinit.rc

# vold: Fix sdcard device location for CDMA boards (thanks paalsteek)
if [ -d /sys/devices/platform/msm_sdcc.3 ]; then
	/bin/sed -i -e 's:/devices/platform/msm_sdcc\.2:/devices/platform/msm_sdcc.3:g' /etc/vold.fstab
fi

KBD=`sed 's/.*physkeyboard=\([0-9a-z_]*\).*/\1/' /sys/class/htc_hw/machine_variant`
cp /init.etc/keymaps/default/*.kl /system/usr/keylayout/
cp /init.etc/keymaps/default/*.kcm* /system/usr/keychars/
if [ -d "/init.etc/keymaps/$KBD" ]
then
	cp /init.etc/keymaps/"$KBD"/*.kl /system/usr/keylayout/
	cp /init.etc/keymaps/"$KBD"/*.kcm* /system/usr/keychars/
fi

[ -f "/data/serialno" ] || echo -e `cat /dev/urandom | tr -dc 'A-Z0-9' | fold -w 12 | head -n 1` >/data/serialno

echo "Android Installed"
