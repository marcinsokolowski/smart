#!/bin/bash

# sbatch -p workq -M $sbatch_cluster pawsey_copy.sh 
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

cd /astro/mwavcs/vcs/1226062160/combined
pwd
date
df -h .

echo "cp /astro/mwavcs/asvo/561137/1226062160_* ."
cp /astro/mwavcs/asvo/561137/1226062160_* .

for tarfile in `ls *.tar`
do
   echo "tar xvf $tarfile"
   tar xvf $tarfile
   
   echo "rm -f $tarfile"
   rm -f $tarfile
done

date
df -h .



