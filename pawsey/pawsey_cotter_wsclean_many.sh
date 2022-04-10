#!/bin/bash

obsid=1274143152
if [[ -n "$1" && "$1" != "-" ]]; then
   obsid=$1
fi

calid=1274143032
if [[ -n "$2" && "$2" != "-" ]]; then
   calid=$2
fi

timefile_template="timestamps_?????.txt"
if [[ -n "$3" && "$3" != "-" ]]; then
   timefile_template=$3
fi

visdir=/astro/mwavcs/msok/mwa/1274143152/10ms/vis/
if [[ -n "$4" && "$4" != "-" ]]; then
   visdir="$4"
fi

# -N to turn off cotter

path=./pawsey_cotter_wsclean.sh

for file in `ls ${timefile_template}`
do
   echo "sbatch -p gpuq -M $sbatch_cluster ${path} ${obsid} ${calid} ${file} ${visdir}"
   sbatch -p gpuq -M $sbatch_cluster ${path} ${obsid} ${calid} ${file} ${visdir}
done
