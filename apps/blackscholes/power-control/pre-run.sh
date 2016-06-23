source apps/parsec-common.sh
NUMBER=400
NTHREADS=`nproc`
BINARY=/local/benchmarks/parsec-3.0/pkgs/apps/blackscholes/obj/$ARCH-linux.gcc-hooks/blackscholes
WINDOW=20
ARGS="$NTHREADS /local/inputs/blackscholes/in_10M.txt out_10M.txt"
PREFIX="BLACKSCHOLES"

export ${PREFIX}_WINDOW_SIZE=$WINDOW
