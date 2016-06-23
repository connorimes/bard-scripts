source apps/parsec-common.sh
NUMBER=100
BINARY=/local/benchmarks/parsec-3.0/pkgs/apps/facesim/obj/$ARCH-linux.gcc-hooks/Benchmarks/facesim/facesim
WINDOW=20
NTHREADS=`nproc`
ARGS="-timing -threads $NTHREADS -lastframe $NUMBER"
PREFIX="FACESIM"

export ${PREFIX}_WINDOW_SIZE=$WINDOW
