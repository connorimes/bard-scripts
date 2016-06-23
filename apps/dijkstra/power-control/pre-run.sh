NUMBER=1000
BINARY=/local/benchmarks/parmibench/Network/Dijkstra/Parallel/dijkstra_parallel_mqueue
WINDOW=20
NTHREADS=`nproc`
ARGS="/local/benchmarks/parmibench/Network/Dijkstra/Parallel/input_small.dat"
PREFIX="DIJKSTRA"

export ${PREFIX}_WINDOW_SIZE=$WINDOW
