#!/bin/bash
# Start executing a performance target, then switch to a power target.
# Connor Imes
# 2015-03-12

# Must run script with root privileges
if [ "$(id -u)" -ne 0 ]
then
	echo "Please run with root privileges"
	exit 1
fi

APP=$1
PERF_TARGET=$2
PWR_TARGET=$3
PERF_PWR_SWITCH_HB=$4
if [ -z "$PERF_PWR_SWITCH_HB" ]
then
	echo "Usage:"
	echo "  $0 <application> <perf_target> <pwr_target> <hb_switch_num>"
	exit 1
fi

CPU_CONFIG_FILE=/etc/poet/cpu_config
if [ ! -e "$CPU_CONFIG_FILE" ]
then
	echo "$CPU_CONFIG_FILE not found"
	exit 1
fi

PRERUN="apps/$APP/power-control/pre-run.sh"
if [ ! -e "$PRERUN" ]
then
	echo "pre-run script not found: $PRERUN"
	exit 1
fi
source "$PRERUN"

export ${PREFIX}_CONSTRAINT="PERFORMANCE"
export ${PREFIX}_MIN_HEART_RATE=$PERF_TARGET
export ${PREFIX}_MAX_HEART_RATE=$PERF_TARGET
export ${PREFIX}_POWER_TARGET=$PWR_TARGET
export ${PREFIX}_PERF_PWR_SWITCH_HB=$PERF_PWR_SWITCH_HB
export HEARTBEAT_ENABLED_DIR=heartenabled/
rm -Rf ${HEARTBEAT_ENABLED_DIR}
mkdir -p ${HEARTBEAT_ENABLED_DIR}

RESULTS_FILE="${PREFIX}_perf_pwr.results"
# frequency and number of cores of highest state
HIGH_STATE_CORES=$(tail -n 1 /etc/poet/cpu_config | awk '{print $2}')

echo "Executing with perf=$PERF_TARGET, pwr=$PWR_TARGET"
hr=''
c=1
while [[ $hr = '' ]] || [[ $c -le 0 ]]
do
	# Start application in highest system setting Bard supports
	source bard_init_state.sh

	echo "taskset $HIGH_STATE_CORES ${BINARY} ${ARGS}"
	taskset "$HIGH_STATE_CORES" "${BINARY}" "${ARGS}" &
	pid=$!
	loop=0
	# sleep while process is still running
	while [ $loop -eq 0 ]
	do
		sleep 5
		ps -p $pid > /dev/null
		loop=$?
	done

	hr=$(tail -n 1 heartbeat.log | awk '// {print $4}')
	power=$(tail -n 1 heartbeat.log | awk '// {print $10}')
	joules=$(echo "scale=4; $NUMBER / $hr * $power" | bc)
	c=$(echo "$power > 0" | bc)

	source hb_cleanup.sh
done

if [ ! -f "$RESULTS_FILE" ]
then
	echo "Target_Rate Rate Power Energy" > "$RESULTS_FILE"
fi
echo "$TARGET $hr $power $joules" >> "$RESULTS_FILE"

sleep 20

