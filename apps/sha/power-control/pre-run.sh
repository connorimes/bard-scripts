#!/bin/bash
export NUMBER=1000
export BINARY=/local/benchmarks/parmibench/Security/sha/sha
WINDOW=50
NTHREADS=$(nproc)
export ARGS="-P -$NTHREADS"
export PREFIX="SHA"

export ${PREFIX}_WINDOW_SIZE=$WINDOW
