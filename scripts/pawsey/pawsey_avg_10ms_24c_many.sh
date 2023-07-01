#!/bin/bash

# WARNING : this should realy be later in the code, but need it here to be used in the ls in the next line:
obsid=1274143152
if [[ -n "$1" && "$1" != "-" ]]; then
   obsid=$1
fi

timestamp_file="timestamps_?????.txt"
if [[ -n "$2" && "$2" != "-" ]]; then
   timestamp_file="$2"
fi

outdir=avg/
if [[ -n "$3" && "$3" != "-" ]]; then
   outdir=$3
fi

avg_final=0
if [[ -n "$4" && "$4" != "-" ]]; then
   avg_final=$4
fi

for subdir in `cat $timestamp_file`
do
   echo "sbatch pawsey_avg_10ms_24c.sh $obsid \"$subdir\" $outdir $avg_final"
   sbatch pawsey_avg_10ms_24c.sh $obsid "$subdir" $outdir $avg_final
done
   
