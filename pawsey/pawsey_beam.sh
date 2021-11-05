#!/bin/bash -l

# WARNING : programs azh2radec and date2date are probably not compiled on galaxy/magnus ..., but I can do it ...
# Example : sbatch -p workq -M $sbatch_cluster $SMART_DIR/bin/pawsey/pawsey_smart_prepare_timestamps.sh 1278106408

#SBATCH --account=pawsey0348
#SBATCH --account=mwavcs
#SBATCH --time=23:59:59
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH --tasks-per-node=1
#SBATCH --mem=64gb
#SBATCH --output=./pawsey_calibrate.o%j
#SBATCH --error=./pawsey_calibrate.e%j
#SBATCH --export=NONE


# echo "srun calibrate -j 16 -applybeam -mwa-path /astro/mwaops/msok/mwa/adrian/2021/1103645160/mwa_pb/data -absmem 40 -m srclist_pumav3_EoR0aegean_EoR1pietro+ForA_1103645160_aocal100.txt -minuv 128 -maxuv 1300 -i 100 1103645160.ms 1103645160_apply_beam.bin"
# srun calibrate -j 16 -applybeam -mwa-path /astro/mwaops/msok/mwa/adrian/2021/1103645160/mwa_pb/data -absmem 40 -m srclist_pumav3_EoR0aegean_EoR1pietro+ForA_1103645160_aocal100.txt -minuv 128 -maxuv 1300 -i 100 1103645160.ms 1103645160_apply_beam.bin

echo "srun beam -2016 -square -proto wsclean_1103645160_briggs-XX-image.fits -ms 1103645160.ms -name mwareduce_beamsquare"
srun beam -2016 -square -proto wsclean_1103645160_briggs-XX-image.fits -ms 1103645160.ms -name mwareduce_beamsquare
