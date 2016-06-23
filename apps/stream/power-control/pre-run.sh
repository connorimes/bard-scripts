NUMBER=500
BINARY=/local/benchmarks/stream/stream_omp
WINDOW=50
NTHREADS=`nproc`
ARGS=""
PREFIX="STREAM"

export ${PREFIX}_WINDOW_SIZE=$WINDOW
