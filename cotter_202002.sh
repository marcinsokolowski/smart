#!/bin/bash -l

# Cotter the data
#SBATCH --account=mwaops
#SBATCH --time=12:00:00
#SBATCH --nodes=1
#SBATCH --tasks-per-node=8
#SBATCH --mem=64gb
#SBATCH --output=/astro/mwaops/msok/log/202002/cotter.o%j
#SBATCH --error=/astro/mwaops/msok/log/202002/cotter.e%j
#SBATCH --export=NONE

cores=1
run="srun --nodes=1 -c $cores --export=all"


obs=1150234552

cd /group/mwasci/msok/test/202002/

df -h .
ls -al

echo "Started at :" > local.log
date >> local.log


# echo "$run wsclean -name wsclean_1192530256_timeindex100 -j 6 -size 500 500  -pol XX,YY,XY,YX -absmem 64 -weight natural -scale 0.008 -minuv-l 30 -interval 100 101  -channelsout 24 1192530256.ms > wsclean_100_101.out"
# $run wsclean -name wsclean_1192530256_timeindex100 -j 6 -size 500 500  -pol XX,YY,XY,YX -absmem 64 -weight natural -scale 0.008 -minuv-l 30 -interval 100 101  -channelsout 24 1192530256.ms > wsclean_100_101.out

. /group/mwaops/PULSAR/psrBash.profile
module use /group/mwa/software/modulefiles
module load cotter

timeres=0.01
freqres=40

# wget http://mwa-metadata01.pawsey.org.au/metadata/fits/?obs_id=${obs} -O ${obs}.metafits

# echo "$run cotter -j $cores -timeres ${timeres} -freqres ${freqres} -noflagautos ${cotter_options} -m $obs.metafits ${bad_tiles_option} -o $obs.ms *gpubox*.fits"
# $run cotter -j $cores -timeres ${timeres} -freqres ${freqres} -noflagautos ${cotter_options} -m $obs.metafits ${bad_tiles_option} -o $obs.ms *gpubox*.fits


echo "$run cotter -absmem 60 -j 12 -timeres 4 -freqres 0.04 -noflagautos  -m ${obs}.metafits -norfi -noflagmissings -allowmissing -offline-gpubox-format -o 1150234552_0-60sec.ms 1150234552_*_2?.fits"
$run cotter -absmem 60 -j 12 -timeres 4 -freqres 0.04 -noflagautos  -m ${obs}.metafits -norfi -noflagmissings -allowmissing -offline-gpubox-format -o 1150234552_10-20sec.ms 1150234552_*_2?.fits



