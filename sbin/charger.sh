#!/bin/sh

case $1 in
    on)
	mkdir /sys/class/leds/amber/brightness
	mkdir /sys/class/leds/green/brightness

	echo 0 > /proc/sys/kernel/hung_task_timeout_secs
	echo 1 > /sys/class/leds/amber/brightness
	echo 0 > /sys/class/leds/green/brightness
	echo 15 > /sys/class/leds/lcd-backlight/brightness
	echo 256000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
        ;;
    off)
        echo 0 > /sys/class/leds/amber/brightness
        echo 0 > /sys/class/leds/green/brightness
        echo 100 > /sys/class/leds/lcd-backlight/brightness
        echo 528000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
        ;;
    --)
        ;;
esac

exit 0

