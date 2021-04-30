#!/bin/bash

n_images_per_job=50
if [[ -n "$1" && "$1" != "-" ]]; then
   n_images_per_job=$1
fi

timesteps_file=timestamps.txt
if [[ -n "$2" && "$2" != "-" ]]; then
   timesteps_file=$2
fi
out_basename=${timesteps_file%%.txt}

n_timesteps=`cat $timesteps_file | wc -l`
max_timestamps=${n_timesteps}
if [[ -n "$3" && "$3" != "-" ]]; then
   max_timestamps=$3
fi

if [[ $n_timesteps -gt $max_timestamps ]]; then
   n_timesteps=$max_timestamps
   echo "WARNING : Number of timestamps to process = $n_timesteps larger than maximum allowed = $max_timestamps -> truncated to n_timesteps := $max_timestamps"
fi

n_jobs=`echo "$n_images_per_job $n_timesteps" | awk '{printf("%d",$2/$1);}'`

echo "##############################################"
echo "PARAMETERS:"
echo "##############################################"
echo "timesteps_file = $timesteps_file"
echo "max_timestamps = $max_timestamps"
echo "n_timesteps   = $n_timesteps"
echo "n_jobs         = $n_jobs"
echo "##############################################"

i=0
while [[ $i -lt $n_jobs ]];
do
   outfile=`echo $i | awk -v out_basename=${out_basename} '{printf("%s_%05d.txt",out_basename,$1);}'`   
   awk -v n_timesteps=${n_images_per_job} -v n_jobs=${n_jobs} -v job=${i} 'BEGIN{start_record=job*n_timesteps+1;end_record=start_record+n_timesteps;}{if(NR>=start_record && NR<end_record){print $0;}}' ${timesteps_file} > ${outfile}
   
   echo "$i : $outfile"

   i=$(($i+1))
done
