source apps/parsec-common.sh
#NUMBER=101
NUMBER=261
BINARY=/local/benchmarks/parsec-3.0/pkgs/apps/bodytrack/obj/$ARCH-linux.gcc-hooks/TrackingBenchmark/bodytrack
WINDOW=20
NTHREADS=`nproc`
ARGS="/local/inputs/bodytrack/sequenceB_261 4 $NUMBER 4000 5 0 $NTHREADS"
PREFIX="BODYTRACK"

export ${PREFIX}_WINDOW_SIZE=$WINDOW
