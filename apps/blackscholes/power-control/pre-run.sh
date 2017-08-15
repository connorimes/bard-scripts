#!/bin/bash
source apps/parsec-common.sh
export NUMBER=400
NTHREADS=$(nproc)
export BINARY=/local/benchmarks/parsec-3.0/pkgs/apps/blackscholes/obj/$ARCH-linux.gcc-hooks/blackscholes
WINDOW=20
export ARGS="$NTHREADS /local/inputs/blackscholes/in_10M.txt out_10M.txt"
export PREFIX="BLACKSCHOLES"

export ${PREFIX}_WINDOW_SIZE=$WINDOW
