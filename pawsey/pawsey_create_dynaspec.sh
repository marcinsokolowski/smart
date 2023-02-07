#!/bin/bash -l

#  sbatch -p workq pawsey_create_dynaspec.sh

# Uses symbolic links are created by pawsey_create_links_10ms.sh script and creates dynamic spectrum

#SBATCH --account=pawsey0348
#SBATCH --account=mwavcs
#SBATCH --time=23:59:00
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --mem=32gb
#SBATCH --output=./pawsey_create_dynaspec.o%j
#SBATCH --error=./pawsey_create_dynaspec.e%j
#SBATCH --export=NONE

obsid=1274143152
if [[ -n "$1" && "$1" != "-" ]]; then
   obsid=$1
fi

# 6000 images is too much to keep in memory on Garrawarla node (max ~350 gb)
# no huge memory is required as it reads each timestamp separetely (not all images into memory at once)
echo "srun create_dynaspec -S 0 -w \"(510,510)-(514,514)\" -o ${obsid} -v -r 1000000.00 -T "wsclean_timeindex%04d" -C 109 -X 0.01 -t 6000 -f \"wsclean_%d_timeindex%04d-%04d-I-dirty.fits\""
srun create_dynaspec -S 0 -w "(510,510)-(514,514)" -o ${obsid} -v -r 1000000.00 -T "wsclean_timeindex%04d" -C 109 -X 0.01 -t 6000 -f "wsclean_%d_timeindex%04d-%04d-I-dirty.fits"
