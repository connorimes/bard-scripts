#!/bin/bash
# Run all on all configurations for this platform

# Whether to use external power meter (0 or 1)
USE_POWERMON=0

# Must run script with root privileges
if [ "$(id -u)" -ne 0 ]
then
  echo "Please run with root privileges"
  exit 1
fi

# Get the app to run (must match directory structure)
APP=$1
if [ -z "$APP" ]
then
  echo "Usage:"
  echo "  $0 <application>"
  exit 1
fi

PRERUN="apps/$APP/power-control/pre-run.sh"
if [ ! -e "$PRERUN" ]
then
  echo "pre-run script not found: $PRERUN"
  exit 1
fi
source "$PRERUN"

export POET_DISABLE_CONTROL=1
export HEARTBEAT_ENABLED_DIR=heartenabled/
rm -Rf ${HEARTBEAT_ENABLED_DIR}
mkdir -p ${HEARTBEAT_ENABLED_DIR}

RESULTS_FILE="${PREFIX}.results"
POWER_MON=./powerQoS/pyWattsup-hank.py
NUM_CORES=$(nproc)
FREQUENCIES=($(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies))
NUM_FREQUENCIES=${#FREQUENCIES[*]}

for (( i=NUM_CORES - 1; i>=0; i-- ))
do

  for (( mask=0x01, ctr=i; ctr > 0; ctr-- ))
  do
    mask=$((mask << 1 | 0x01))
  done
  mask=$(printf "0x%X" $mask) # Get the hex value as a string

  for (( j=0; j<NUM_FREQUENCIES; j++ ))
  do

    # Configure the CPU speed
    freq=${FREQUENCIES[$j]}
    for (( k=0; k<NUM_CORES; k++ ))
    do
      echo "Setting speed $freq on cpu$k"
      echo "userspace" > /sys/devices/system/cpu/cpu$k/cpufreq/scaling_governor
      echo "$freq" > /sys/devices/system/cpu/cpu$k/cpufreq/scaling_setspeed
    done
    sleep 1

    hr=''
    power=''
    joules=''
    c=1
    while [[ $hr = '' ]]||[[ $power = '' ]]||[[ $joules = '' ]]||[[ $c -le 0 ]]
    do
      if [ $USE_POWERMON -gt 0 ]
      then
        $POWER_MON start
      fi

      CMD=(taskset $mask "${BINARY}" "${ARGS[@]}")
      echo "${CMD[@]}"
      "${CMD[@]}"

      if [ $USE_POWERMON -gt 0 ]
      then
        $POWER_MON stop > power.txt
        power2=$(awk '/Pavg/ {print $2}' power.txt)
        joules2=$(awk '/Joules/ {print $2}' power.txt)
        cp power.txt "power_$mask-$freq.txt"
      fi

      hr=$(tail -n 1 heartbeat.log | awk '// {print $4}')
      power=$(tail -n 1 heartbeat.log | awk '// {print $10}')
      joules=$(echo "scale=4; $NUMBER / $hr * $power" | bc)
      c=$(echo "$power > 0" | bc)

      source hb_cleanup.sh
    done

    if [ ! -f "$RESULTS_FILE" ]
    then
      echo "cores freq Rate Power Energy WU_PWR_AVG WU_ENERGY" > "$RESULTS_FILE"
    fi
    echo "$mask $freq $hr $power $joules $power2 $joules2" >> "$RESULTS_FILE"
    
    cp heartbeat.log "heartbeat_$mask-$freq.log"

    sleep 20

  done
done

