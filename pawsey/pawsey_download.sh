#!/bin/bash

# sbatch -p workq -M $sbatch_cluster pawsey_download.sh OBSID
# example request.csv file :
#   obs_id=1226062160, job_type=v, delivery=astro, duration=1800, offset=0
# see Susmita's wiki : https://wiki.mwatelescope.org/display/MP/Using+the+new+MWA+ASVO


#SBATCH --account=mwavcs
#SBATCH --time=23:59:00
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --mem=16gb
#SBATCH --output=./pawsey_download.o%j
#SBATCH --error=./pawsey_download.e%j
#SBATCH --export=NONE

source ~/asvo_profile

# can be removed from here - just to show what needs to be loaded on Garrawarla:
echo "module load manta-ray-client/master"
module load manta-ray-client/master

# obsid=1255443816
obsid=1226062160 # Gayatri:
# obsid=1274143152 # SMART
if [[ -n "$1" && "$1" != "-" ]]; then
   obsid=$1
fi

# echo "obs_id=${obsid}, job_type=c, download_type=vis, timeres=4, freqres=40, conversion=ms, edgewidth=80, allowmissing=true, noflagautos=true" > request.csv
echo "obs_id=${obsid}, job_type=v, delivery=astro, duration=1800, offset=0" > request.csv
mwa_client --csv=request.csv 

# echo "unzip *.zip"
# unzip *.zip

