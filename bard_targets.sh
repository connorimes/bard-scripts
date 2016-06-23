#!/bin/bash
# Execute performance/power targets using Bard: 5%, 25%, 50%, 75%, 95%
# Connor Imes
# 2014-08-13

# Must run script with root privileges
if [ `id -u` -ne 0 ]
then
	echo "Please run with root privileges"
	exit 1
fi

TARGET_TYPE=$1
APP=$2
MAX_TARGET=$3
MIN_TARGET=$4
if [ -z $APP ] || [ -z $MAX_TARGET ] || [ -z $TARGET_TYPE ] || [[ ! "PERFORMANCE POWER" =~ $TARGET_TYPE ]]
then
	echo "Usage:"
	echo "  $0 <PERFORMANCE|POWER> <application> <max_possible> <min_possible>"
	exit 1
fi
if [ -z $MIN_TARGET ]
then
	MIN_TARGET=0
fi

# Get the targets to execute
TARGETS=()
for f in 0.05 0.25 0.5 0.75 0.95
do
	TARGETS+=(`echo "scale=4; ($MAX_TARGET - $MIN_TARGET) * $f + $MIN_TARGET" | bc`)
done
NUM_TARGETS=${#TARGETS[*]}

echo "Targets ($NUM_TARGETS): ${TARGETS[*]}"

# Iterate over all performance targets
for (( i=0; i<$NUM_TARGETS; i++ ))
do
	target=${TARGETS[$i]}
	id="BAD"
	if [ $TARGET_TYPE == "PERFORMANCE" ]
	then
		id="perf_$i"
		./bard_perf_target.sh $APP $target
	elif [ $TARGET_TYPE == "POWER" ]
	then
		id="pwr_$i"
		./bard_pwr_target.sh $APP $target
	fi

	if [ -e "power.txt" ]
	then
		cp power.txt power_$id.txt
	fi
	cp heartbeat.log heartbeat_$id.log
	cp bard.log bard_$id.log
done
