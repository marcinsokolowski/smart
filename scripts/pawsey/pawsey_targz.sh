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
#SBATCH --output=/home/msok/log/pawsey_targz.o%j
#SBATCH --error=/home/msok/log/pawsey_targz.e%j
#SBATCH --export=NONE

# du -sk 1275085816/vis 1275172216/vis 1275258616/vis 1275431416/vis 1276725752/vis
cd /astro/mwavcs/vcs/
pwd
date
df -h .

for obsid in `ls -d 1275085816 1275172216 1275258616 1275431416 1276725752`
do
   cd ${obsid}
   date
   echo "tar zcvf ${obsid}_vis.tar.gz vis/"
   tar zcvf ${obsid}_vis.tar.gz vis/
   echo "$obsid done at:"
   date
   cd ..
done

date
df -h .

