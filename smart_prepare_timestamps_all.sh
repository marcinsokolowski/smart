#!/bin/bash

# WARNING : programs azh2radec and date2date are probably not compiled on galaxy/magnus ..., but I can do it ...

smart_bin=$SMART_DIR/bin/


obsid=1150234552
if [[ -n "$1" && "$1" != "-" ]]; then
   obsid=$1
fi

gpufits_files_dir=/astro/mwaops/vcs/1150234552/vis
if [[ -n "$2" && "$2" != "-" ]]; then
   gpufits_files_dir=$2
fi

processing_dir=`pwd`
if [[ -n "$3" && "$3" != "-" ]]; then
   processing_dir="$3"
fi

# for drift scan observations :
azim=33.6901
if [[ -n "$4" && "$4" != "-" ]]; then
   azim=$4
fi

alt=64.6934
if [[ -n "$5" && "$5" != "-" ]]; then
   alt=$5
fi

# gpu_list=1255444104_gpufits.list
# if [[ -n "$6" && "$6" != "-" ]]; then
#   gpu_list=$6
# fi


# cd $gpufits_files_dir
cd $processing_dir
ls $gpufits_files_dir > gpu_list
cat gpu_list  | awk '{print substr($1,12,14);}' | sort -u > ${processing_dir}/timestamps.txt
pwd


cd ${processing_dir}
pwd
date

# download metafits 
url="http://ws.mwatelescope.org/metadata/fits?obs_id="
echo "wget ${url}${obsid} -O ${obsid}.metafits"
wget ${url}${obsid} -O ${obsid}.metafits


metafits=${obsid}.metafits

while read line # example 
do
   t=$line
   
   t_dtm=`echo $t | awk '{print substr($1,1,8)"_"substr($1,9);}'`
   t_dateobs=`echo $t | awk '{print substr($1,1,4)"-"substr($1,5,2)"-"substr($1,7,2)"T"substr($1,9,2)":"substr($1,11,2)":"substr($1,13,2);}'`
   t_ux=`date2date -ut2ux=${t_dtm} | awk '{print $3;}'`
   t_gps=`ux2gps! $t_ux`


   ra=`azh2radec $t_ux mwa $azim $alt | awk '{print $4;}'`
   dec=`azh2radec $t_ux mwa $azim $alt | awk '{print $6;}'`
   
   cp $metafits ${t}.metafits
   echo "python ${smart_bin}/fix_metafits_time_radec.py ${t}.metafits $t_dateobs $t_gps $ra $dec"
   python ${smart_bin}/fix_metafits_time_radec.py ${t}.metafits $t_dateobs $t_gps $ra $dec   
   
done < timestamps.txt
