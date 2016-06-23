NUMBER=1000
BINARY=/local/benchmarks/parmibench/Security/sha/sha
WINDOW=50
NTHREADS=`nproc`
ARGS="-P -$NTHREADS"
PREFIX="SHA"

export ${PREFIX}_WINDOW_SIZE=$WINDOW
