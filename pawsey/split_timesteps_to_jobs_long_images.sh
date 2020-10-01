#!/bin/bash

n_images_per_job=60
if [[ -n "$1" && "$1" != "-" ]]; then
   n_images_per_job=$1
fi

timesteps_file=timestamps.txt
if [[ -n "$2" && "$2" != "-" ]]; then
   timesteps_file=$2
fi
out_basename=${timesteps_file%%.txt}

subdir=${n_images_per_job}seconds
if [[ -n "$3" && "$3" != "-" ]]; then
   subdir="$3"
fi


mkdir ${subdir}
cd ${subdir}

echo "cp ../${timesteps_file} ."
cp ../${timesteps_file} .

n_timesteps=`cat $timesteps_file | wc -l`
n_jobs=`echo "$n_images_per_job $n_timesteps" | awk '{printf("%d",$2/$1);}'`

echo "##############################################"
echo "PARAMETERS:"
echo "##############################################"
echo "timesteps_file = $timesteps_file"
echo "n_timesteps   = $n_timesteps"
echo "n_jobs         = $n_jobs"
echo "##############################################"

i=0
while [[ $i -lt $n_jobs ]];
do
   outfile=`echo $i | awk -v out_basename=${out_basename} '{printf("%s_%05d.txt",out_basename,$1);}'`   
   awk -v n_timesteps=${n_images_per_job} -v n_jobs=${n_jobs} -v job=${i} 'BEGIN{start_record=job*n_timesteps+1;end_record=start_record+n_timesteps;}{if(NR>=start_record && NR<end_record){print $0;}}' ${timesteps_file} > ${outfile}
   
   first_timestamp=`head -1 ${outfile}`
   
   echo "cp ../${first_timestamp}.metafits ."
   cp ../${first_timestamp}.metafits .
   
   echo "python /opt/caastro/bighorns//bin//setkey.py ${first_timestamp}.metafits EXPOSURE 60 --int"
   python /opt/caastro/bighorns//bin//setkey.py ${first_timestamp}.metafits EXPOSURE 60 --int
   
   echo "$i : $outfile"

   i=$(($i+1))
done
