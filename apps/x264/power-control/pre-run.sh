#!/bin/bash
source apps/parsec-common.sh
#sunflower, ducks_take_off_1080p, rush_hour, old_town_cross_1080p = 500
#native = 512
#phases = 1500
VIDEO=ducks_take_off_1080p.yuv
export NUMBER=500
export BINARY=/local/benchmarks/parsec-3.0/pkgs/apps/x264/inst/$ARCH-linux.gcc-hooks/bin/x264
WINDOW=20
NTHREADS=$(nproc)
export ARGS="--quiet --qp 20 --partitions b8x8,i4x4 --ref 5 --direct auto --b-pyramid --weightb --mixed-refs --no-fast-pskip --me umh --subme 7 --analyse b8x8,i4x4 --threads $NTHREADS -o test.264 /local/inputs/x264/$VIDEO 1920x1080 --frames $NUMBER"
export PREFIX="X264"

export ${PREFIX}_WINDOW_SIZE=$WINDOW
