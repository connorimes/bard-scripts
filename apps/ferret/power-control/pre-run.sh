source apps/parsec-common.sh
NUMBER=3500
BINARY=/local/benchmarks/parsec-3.0/pkgs/apps/ferret/inst/$ARCH-linux.gcc-hooks/bin/ferret
WINDOW=20
NTHREADS=`nproc`
ARGS="/local/inputs/ferret/corel lsh /local/inputs/ferret/queries 50 20 $NTHREADS output.txt"
PREFIX="FERRET"

export ${PREFIX}_WINDOW_SIZE=$WINDOW
