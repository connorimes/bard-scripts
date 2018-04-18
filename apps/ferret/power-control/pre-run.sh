#!/bin/bash
source apps/parsec-common.sh
export NUMBER=3500
export BINARY="/local/benchmarks/parsec-3.0/pkgs/apps/ferret/inst/$ARCH-linux.gcc-hooks/bin/ferret"
WINDOW=20
NTHREADS=$(nproc)
export ARGS=("/local/inputs/ferret/corel" lsh "/local/inputs/ferret/queries" 50 20 $NTHREADS "output.txt")
export PREFIX="FERRET"

export ${PREFIX}_WINDOW_SIZE=$WINDOW
