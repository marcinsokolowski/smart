#!/bin/bash -l

# Example : sbatch -p workq -M $sbatch_cluster pawsey_calibrate_obs.sh OBSID[default 1276625432] SKY_MODEL_TEXT_FILE[default sky_model.txt]
#    SKY_MODEL_TEXT_FILE - can be output from PUMA or any other model file

#SBATCH --account=mwavcs
#SBATCH --time=23:59:59
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH --tasks-per-node=1
#SBATCH --mem=64gb
#SBATCH --output=./pawsey_calibrate.o%j
#SBATCH --error=./pawsey_calibrate.e%j
#SBATCH --export=NONE

calid=1276625432
if [[ -n "$1" && "$1" != "-" ]]; then
   calid=$1
fi

sky_model_file=sky_model.txt
if [[ -n "$2" && "$2" != "-" ]]; then
   sky_model_file=$2
fi

echo "###############################################################"
echo "PARAMETERS:"
echo "###############################################################"
echo "calid = $calid"
echo "sky_model_file = $sky_model_file"
echo "###############################################################"

# On Garrawarla required these lines :
echo "module load mwa-reduce/master"
module load mwa-reduce/master

# Uses only UV range 128 - 1300 wavelenghts (upper limit can be removed) , I also used just lower cut-off -minuv 58 in another analysis
# I am not sure where the 128 - 1300 limit comes from exactly, so may be revised when used 
echo "srun calibrate -j 16 -applybeam -mwa-path /pawsey/mwa -absmem 64 -m $sky_model_file -minuv 128 -maxuv 1300 -i 100 ${calid}.ms ${calid}_apply_beam.bin"
srun calibrate -j 16 -applybeam -mwa-path /pawsey/mwa -absmem 64 -m $sky_model_file -minuv 128 -maxuv 1300 -i 100 ${calid}.ms ${calid}_apply_beam.bin
