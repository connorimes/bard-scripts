#!/bin/bash
# 
# Set the cpufreq scaling governor for all cores.
# The governor value to use can be passed as the first argument to the script.
# The default value is 'ondemand'.
#
# Connor Imes
# 7/26/2014

# Must run script with root privileges
if [ "$(id -u)" -ne 0 ]
then
  echo "Please run with root privileges"
  exit 1
fi

# Get the number of cores
ncores=$(nproc)

# Decide on the scaling governor
governor=$1
if [ $# -eq 0 ]
then
  echo "No governor value received as argument, defaulting to 'ondemand'"
  governor=ondemand
fi

# Apply the governor setting to each core
for (( i=0; i<ncores; i++ ))
do
  echo "Setting $governor scaling governor on cpu$i"
  echo "$governor" > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor
done

