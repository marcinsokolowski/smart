#!/bin/bash

obsid=1274143152
if [[ -n "$1" && "$1" != "-" ]]; then
   obsid=$1
fi

timefile_template="timestamps_00000.txt"
if [[ -n "$2" && "$2" != "-" ]]; then
   timefile_template=$2
fi

wsclean_options=""
if [[ -n "$3" && "$3" != "-" ]]; then
   wsclean_options="$3"
fi

size=4096
if [[ -n "$4" && "$4" != "-" ]]; then
   size=$4
fi

for timestamp in `cat ${timefile_template}`
do
   echo "sbatch -p gpuq -M $sbatch_cluster $SMART_DIR/bin/pawsey/submit_10ms_dirty_images.sh ${obsid} ${timestamp} \"${wsclean_options}\" ${size}" 
   sbatch -p gpuq -M $sbatch_cluster $SMART_DIR/bin/pawsey/submit_10ms_dirty_images.sh ${obsid} ${timestamp} "${wsclean_options}" ${size}
done
