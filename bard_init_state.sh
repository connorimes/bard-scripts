#!/bin/bash
# Start application in highest system setting Bard supports
# Connor Imes
# 2015-01-15

# Must run script with root privileges
if [ "$(id -u)" -ne 0 ]
then
	echo "Please run with root privileges"
	exit 1
fi

if [ -z "$CPU_CONFIG_FILE" ]; then
	CPU_CONFIG_FILE=/etc/poet/cpu_config
fi
if [ ! -e "$CPU_CONFIG_FILE" ]; then
	echo "$CPU_CONFIG_FILE not found"
	exit 1
fi

HIGH_STATE_FREQS=$(tail -n 1 $CPU_CONFIG_FILE | awk '{print $3}')

IFS=',' read -a freqs <<< $HIGH_STATE_FREQS
k=-1
for freq in "${freqs[@]}"; do
	((k++))
	if [ "$freq" == "-" ]; then
		continue;
	fi
	echo "Resetting speed $freq on cpu$k"
	userspace=$(grep "userspace" /sys/devices/system/cpu/cpu$k/cpufreq/scaling_available_governors)
	if [ -z "$userspace" ]; then
		echo performance > /sys/devices/system/cpu/cpu$k/cpufreq/scaling_governor
		echo "$freq" > /sys/devices/system/cpu/cpu$k/cpufreq/scaling_max_freq
	else
		echo "userspace" > /sys/devices/system/cpu/cpu$k/cpufreq/scaling_governor
		echo "$freq" > /sys/devices/system/cpu/cpu$k/cpufreq/scaling_setspeed
	fi
done

