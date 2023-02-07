#!/bin/bash -l

# Cotter the data
#SBATCH --account=mwaops
#SBATCH --time=12:00:00
#SBATCH --nodes=1
#SBATCH --tasks-per-node=4
#SBATCH --mem=20gb
#SBATCH --output=/astro/mwaops/msok/log/cotter.o%j
#SBATCH --error=/astro/mwaops/msok/log/cotter.e%j
#SBATCH --export=NONE

cores=1
run="srun  --nodes=1 -c $cores --export=all"


obs=1241518520

cd /group/mwaops/vcs/1241518520/cal/${obs}/vis/

echo "Started at :" > local.log
date >> local.log


# echo "$run wsclean -name wsclean_1192530256_timeindex100 -j 6 -size 500 500  -pol XX,YY,XY,YX -absmem 64 -weight natural -scale 0.008 -minuv-l 30 -interval 100 101  -channelsout 24 1192530256.ms > wsclean_100_101.out"
# $run wsclean -name wsclean_1192530256_timeindex100 -j 6 -size 500 500  -pol XX,YY,XY,YX -absmem 64 -weight natural -scale 0.008 -minuv-l 30 -interval 100 101  -channelsout 24 1192530256.ms > wsclean_100_101.out

. /group/mwaops/PULSAR/psrBash.profile

timeres=0.01
freqres=40

wget http://mwa-metadata01.pawsey.org.au/metadata/fits/?obs_id=${obs} -O ${obs}.metafits

echo "$run cotter -j $cores -timeres ${timeres} -freqres ${freqres} -noflagautos ${cotter_options} -m $obs.metafits ${bad_tiles_option} -o $obs.ms *gpubox*.fits"
$run cotter -j $cores -timeres ${timeres} -freqres ${freqres} -noflagautos ${cotter_options} -m $obs.metafits ${bad_tiles_option} -o $obs.ms *gpubox*.fits


