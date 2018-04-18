#!/bin/bash
export NUMBER=1000
export BINARY="/local/benchmarks/parmibench/Network/Dijkstra/Parallel/dijkstra_parallel_mqueue"
WINDOW=20
export ARGS=("/local/benchmarks/parmibench/Network/Dijkstra/Parallel/input_small.dat")
export PREFIX="DIJKSTRA"

export ${PREFIX}_WINDOW_SIZE=$WINDOW
