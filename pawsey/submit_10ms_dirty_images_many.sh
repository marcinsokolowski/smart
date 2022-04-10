#!/bin/bash

obsid=1274143152
if [[ -n "$1" && "$1" != "-" ]]; then
   obsid=$1
fi

timefile_template="timestamps_00000.txt"
if [[ -n "$2" && "$2" != "-" ]]; then
   timefile_template=$2
fi


for timestamp in `cat ${timefile_template}`
do
   echo "sbatch -p gpuq -M $sbatch_cluster ./submit_10ms_dirty_images.sh ${obsid} ${timestamp}"
   sbatch -p gpuq -M $sbatch_cluster ./submit_10ms_dirty_images.sh ${obsid} ${timestamp} 
done
