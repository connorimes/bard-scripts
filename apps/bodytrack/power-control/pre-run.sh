#!/bin/bash
source apps/parsec-common.sh
# export NUMBER=101
export NUMBER=261
export BINARY=/local/benchmarks/parsec-3.0/pkgs/apps/bodytrack/obj/$ARCH-linux.gcc-hooks/TrackingBenchmark/bodytrack
WINDOW=20
NTHREADS=$(nproc)
export ARGS="/local/inputs/bodytrack/sequenceB_261 4 $NUMBER 4000 5 0 $NTHREADS"
export PREFIX="BODYTRACK"

export ${PREFIX}_WINDOW_SIZE=$WINDOW
