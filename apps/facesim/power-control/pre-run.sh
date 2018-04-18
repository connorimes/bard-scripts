#!/bin/bash
source apps/parsec-common.sh
export NUMBER=100
export BINARY="/local/benchmarks/parsec-3.0/pkgs/apps/facesim/obj/$ARCH-linux.gcc-hooks/Benchmarks/facesim/facesim"
WINDOW=20
NTHREADS=$(nproc)
export ARGS=(-timing -threads $NTHREADS -lastframe $NUMBER)
export PREFIX="FACESIM"

export ${PREFIX}_WINDOW_SIZE=$WINDOW
