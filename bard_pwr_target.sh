#!/bin/bash
# Execute a single power target
# Connor Imes
# 2015-01-15

# Must run script with root privileges
if [ `id -u` -ne 0 ]
then
	echo "Please run with root privileges"
	exit 1
fi

APP=$1
TARGET=$2
if [ -z $APP ] || [ -z $TARGET ]
then
	echo "Usage:"
	echo "  $0 <application> <pwr_target>"
	exit 1
fi

CPU_CONFIG_FILE=/etc/poet/cpu_config
if [ ! -e $CPU_CONFIG_FILE ]
then
	echo "$CPU_CONFIG_FILE not found"
	exit 1
fi

PRERUN=apps/$APP/power-control/pre-run.sh
if [ ! -e $PRERUN ]
then
	echo "pre-run script not found: $PRERUN"
	exit 1
fi
source $PRERUN

export ${PREFIX}_CONSTRAINT="POWER"
export ${PREFIX}_POWER_TARGET=$TARGET
export HEARTBEAT_ENABLED_DIR=heartenabled/
rm -Rf ${HEARTBEAT_ENABLED_DIR}
mkdir -p ${HEARTBEAT_ENABLED_DIR}

RESULTS_FILE=${PREFIX}"_pwr.results"
# frequency and number of cores of highest state
HIGH_STATE_CORES=`tail -n 1 $CPU_CONFIG_FILE | awk '{print $2}'`

echo "Executing with power target value: $TARGET"
hr=''
c=1
while [[ $hr = '' ]] || [[ $c -le 0 ]]
do
	# Start application in highest system setting Bard supports
	source bard_init_state.sh

	echo taskset $HIGH_STATE_CORES ${BINARY} ${ARGS}
	taskset $HIGH_STATE_CORES ${BINARY} ${ARGS} & 
	pid=$!
	loop=0
	# sleep while process is still running
	while [ $loop -eq 0 ]
	do
		sleep 5
		ps -p $pid > /dev/null
		loop=$?
	done

	hr=`tail -n 1 heartbeat.log | awk '// {print $4}'`
	power=`tail -n 1 heartbeat.log | awk '// {print $10}'`
	joules=`echo "scale=4; $NUMBER / $hr * $power" | bc`
	c=$(echo "$power > 0" | bc)

	source hb_cleanup.sh
done

if [ ! -f $RESULTS_FILE ]
then
	echo "Target_Power Rate Power Energy" > $RESULTS_FILE
fi
echo $TARGET $hr $power $joules >> $RESULTS_FILE

sleep 20

