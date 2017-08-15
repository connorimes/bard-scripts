#!/bin/bash
# Take a results file from the shmoo script and convert to Bard configs.
#
# Hank Hoffmann
# Connor Imes
# 2015-02-27
#
RESULTS_FILE=$1
CTL_CFG="control_config"
CPU_CFG="cpu_config"

if [ -z "$RESULTS_FILE" ]
then
	echo "Usage:"
	echo "  $0 <results_file>"
	exit 1
fi

if [ ! -e "$RESULTS_FILE" ]
then
	echo "Could not find file: $RESULTS_FILE"
	exit 1
fi

if [ -e "$CTL_CFG" ] || [ -e "$CPU_CFG" ]
then
	echo "$CTL_CFG or $CPU_CFG already exist. Stopping."
	exit 1
fi

# Get the data lines (not the header)
lines=$(wc "$RESULTS_FILE" | awk '{print $1-1}')
tail -n "$lines" "$RESULTS_FILE" | sort -n -k4 > "$RESULTS_FILE.temp"

# create the config files
printf "#id\tspeedup\tpowerup\tidle_partner_id\n" > "$CTL_CFG"
printf "#id\tcores\tfreqs\n" > "$CPU_CFG"
i=0
perfscale=100000
powscale=100000
last=0
while read line; do
	perf=$(echo "$line" | awk '{print $3}')
	pow=$(echo "$line" | awk '{print $4}')
	lt=$(echo "$perf <= $last" | bc)
	if [ "$lt" -eq 1 ]; then
		continue;
	fi
	last=$perf
	if [ $i -eq 0 ]; then
		# normalize values
		perfscale=$perf
		powscale=$pow
	fi

	# read the fields
	cores=$(echo "$line" | awk '{print $1}')
	freq=$(echo "$line" | awk '{print $2}')
	speedup=$(bc -l <<< "scale=6; $perf/$perfscale")
	powerup=$(bc -l <<< "scale=6; $pow/$powscale")
	# produce a comma-delimited list of frequencies
	print_freq=$((cores & 0x01))
	tmpcores=$((cores >> 1))
	if [ $print_freq -eq 1 ]; then
		freqs=$freq
	else
		freqs="-"
	fi
	while [[ $tmpcores -ne 0x00 ]]; do
		if [ $print_freq -eq 1 ]; then
			freqs="$freqs,$freq"
		else
			freqs="$freqs,-"
		fi
		tmpcores=$((tmpcores >> 1))
		print_freq=$((tmpcores & 0x01))
	done
	# print to file
	printf "%s\t%s\t%s\n" "$i" "$cores" "$freqs" >> "$CPU_CFG"
	printf "%s\t%s\t%s\t0\n" >> "$i" "$speedup" "$powerup" "$CTL_CFG"
	((i++))	
done < "$RESULTS_FILE.temp"

# cleanup
rm "$RESULTS_FILE.temp"
