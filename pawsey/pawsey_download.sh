#!/bin/bash

# sbatch -p workq -M $sbatch_cluster pawsey_download.sh OBSID

#SBATCH --account=mwaops
#SBATCH --time=23:59:00
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --mem=16gb
#SBATCH --output=./pawsey_download.o%j
#SBATCH --error=./pawsey_download.e%j
#SBATCH --export=NONE

# can be removed from here - just to show what needs to be loaded on Garrawarla:
echo "module load manta-ray-client/master"
module load manta-ray-client/master

obsid=1255443816
if [[ -n "$1" && "$1" != "-" ]]; then
   obsid=$1
fi

echo "obs_id=${obsid}, job_type=c, download_type=vis, timeres=4, freqres=40, conversion=ms, edgewidth=80, allowmissing=true, noflagautos=true" > request.csv
mwa_client --csv=request.csv --dir=./

echo "unzip *.zip"
unzip *.zip

