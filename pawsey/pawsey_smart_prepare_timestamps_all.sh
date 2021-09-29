#!/bin/bash -l

# WARNING : programs azh2radec and date2date are probably not compiled on galaxy/magnus ..., but I can do it ...
# Example : sbatch -p workq -M $sbatch_cluster $SMART_DIR/bin/pawsey/pawsey_smart_prepare_timestamps.sh 1278106408

#SBATCH --account=pawsey0348
#SBATCH --account=mwavcs
#SBATCH --time=23:59:00
#SBATCH --nodes=1
#SBATCH --tasks-per-node=8
#SBATCH --mem=16gb
#SBATCH --output=./smart.o%j
#SBATCH --error=./smart.e%j
#SBATCH --export=NONE

echo "DEBUG : COMP = $COMP"
if [[ -s $HOME/smart/bin/$COMP/env ]]; then
   echo "source $HOME/smart/bin/$COMP/env"
   source $HOME/smart/bin/$COMP/env
else
   echo "WARNING : file $HOME/smart/bin/$COMP/env not found -> most likely non-PAWSEY system"
fi

smart_bin=$SMART_DIR/bin/


obsid=1194350120
if [[ -n "$1" && "$1" != "-" ]]; then
   obsid=$1
fi

# download metafits 
if [[ ! -s ${obsid}.metafits || $force -gt 0 ]]; then
   url="http://ws.mwatelescope.org/metadata/fits?obs_id="
   echo "wget ${url}${obsid} -O ${obsid}.metafits"
   wget ${url}${obsid} -O ${obsid}.metafits
else
   echo "INFO : metafits file ${obsid}.metafits already exists -> no action required"
fi
metafits=${obsid}.metafits


gpufits_files_dir=/astro/mwavcs/vcs/${obsid}/vis
if [[ -n "$2" && "$2" != "-" ]]; then
   gpufits_files_dir=$2
fi

processing_dir=`pwd`
if [[ -n "$3" && "$3" != "-" ]]; then
   processing_dir="$3"
fi

# for drift scan observations :
# azim=33.6901
azim=`fitshdr $metafits | grep AZIMUTH | awk '{idx=index($0,"=");print substr($0,idx+1);}' | awk '{print $1;}'`
fitshdr $metafits | grep AZIMUTH
if [[ -n "$4" && "$4" != "-" ]]; then
   azim=$4
fi

# alt=64.6934
alt=`fitshdr $metafits | grep ALTITUDE | awk '{idx=index($0,"=");print substr($0,idx+1);}' | awk '{print $1;}'`
fitshdr $metafits | grep ALTITUDE
if [[ -n "$5" && "$5" != "-" ]]; then
   alt=$5
fi

n_channels=768
if [[ -n "$6" && "$6" != "-" ]]; then
   n_channels=$6
fi

# remote_dir=/group/mwasci/msok/test/202002/${obsid}/
remote_dir=
if [[ -n "$7" && "$7" != "-" ]]; then
   remote_dir=$7
fi

jobs_per_file=50
if [[ -n "$8" && "$8" != "-" ]]; then
   jobs_per_file=$8
fi

max_timestamps=-
if [[ -n "$9" && "$9" != "-" ]]; then
   max_timestamps=$9
fi

calid=-1
if [[ -n "${10}" && "${10}" != "-" ]]; then
   calid=${10}
fi

force=0

echo "#################################################################################"
echo "PARAMETERS:"
echo "#################################################################################"
echo "obsid = $obsid ( $metafits )"
echo "calid = $calid ( if < 0 -> no flagging applied in metafits files)"
echo "gpufits_files_dir = $gpufits_files_dir"
echo "processing_dir    = $processing_dir"
echo "azim              = $azim"
echo "alt               = $alt"
echo "n_channels        = $n_channels"
echo "force             = $force"
echo "remote_dir        = $remote_dir"
echo "jobs_per_file     = $jobs_per_file"
echo "max_timestamps    = $max_timestamps"
echo "#################################################################################"

# just to reflect on the parameters (check if correct)
# echo "Please verify if these parameters are correct ..."
# sleep 5



# gpu_list=1255444104_gpufits.list
# if [[ -n "$6" && "$6" != "-" ]]; then
#   gpu_list=$6
# fi

flag_options=""
if [[ $calid -gt 0 ]]; then
   echo "getasvocal.sh ${calid} ${n_channels}"
   getasvocal.sh ${calid} ${n_channels}     
   
   if [[ -s flagged_tiles.txt ]]; then
      flag_options="--flag_file=flagged_tiles.txt"
      echo "Flag file flagged_tiles.txt exists -> adding options $flag_options"      
   else
      echo "WARNING : file flagged_tiles.txt not found"
   fi
else
   echo "WARNING : calibration CALID not specified -> cannot flag tiles in metafits files"
fi

# cd $gpufits_files_dir
cd $processing_dir
if [[ ! -s gpu_list ]]; then
   if [[ -d ${gpufits_files_dir} ]]; then
      echo "ls $gpufits_files_dir | grep fits | grep gpubox > gpu_list"
      ls $gpufits_files_dir | grep fits | grep gpubox > gpu_list
   else      
      echo "ssh garrawarla.pawsey.org.au \"ls ${gpufits_files_dir}\" | grep fits | grep gpubox > gpu_list"
      ssh garrawarla.pawsey.org.au "ls ${gpufits_files_dir}" | grep fits | grep gpubox > gpu_list      
   fi
else
   echo "DEBUG : file gpu_list already exists with number of lines:"
   wc gpu_list   
   echo "DEBUG : not overwritting"
fi   
cat gpu_list  | awk '{print substr($1,12,14);}' | sort -u > ${processing_dir}/timestamps.txt
pwd


cd ${processing_dir}
pwd
date

# while read line # example 
# do
#   t=$line
#   
#   if [[ ! -s ${t}.metafits || $force -gt 0 ]]; then    
#      t_dtm=`echo $t | awk '{print substr($1,1,8)"_"substr($1,9);}'`
#      t_dateobs=`echo $t | awk '{print substr($1,1,4)"-"substr($1,5,2)"-"substr($1,7,2)"T"substr($1,9,2)":"substr($1,11,2)":"substr($1,13,2);}'`
#      t_ux=`date2date -ut2ux=${t_dtm} | awk '{print $3;}'`
#      t_gps=`ux2gps! $t_ux`
#
#      echo "azh2radec $t_ux mwa $azim $alt"
#      ra=`azh2radec $t_ux mwa $azim $alt | awk '{print $4;}'`
#      dec=`azh2radec $t_ux mwa $azim $alt | awk '{print $6;}'`
#   
#      cp $metafits ${t}.metafits
#      echo "python ${smart_bin}/fix_metafits_time_radec.py ${t}.metafits $t_dateobs $t_gps $ra $dec --n_channels=${n_channels}"
#      python ${smart_bin}/fix_metafits_time_radec.py ${t}.metafits $t_dateobs $t_gps $ra $dec  --n_channels=${n_channels}
#   else
#      echo "INFO : ${t}.metafits already exists -> ignored"
#   fi   
# done < timestamps.txt

echo "python ${smart_bin}/fix_metafits_time_radec_all.py timestamps.txt --obsid=$obsid"
python ${smart_bin}/fix_metafits_time_radec_all.py timestamps.txt --obsid=$obsid


echo "$SMART_DIR/bin/pawsey//split_timesteps_to_jobs.sh $jobs_per_file timestamps.txt $max_timestamps"
$SMART_DIR/bin/pawsey//split_timesteps_to_jobs.sh $jobs_per_file timestamps.txt $max_timestamps

if [[ -n "$remote_dir" ]]; then
   echo "INFO : copying resulting metafits files and timestamp files to remote directory : $remote_dir"
   
   # head -10 timestamps_00000.txt > timestamps_test.txt
   all_count=`cat timestamps_?????.txt | wc -l`
   cat timestamps_?????.txt | awk -v all_count=${all_count} '{checker=int(all_count/10);if((FNR%checker)==0 && FNR>1){print $0;}}' > timestamps_test.txt
   
   echo "ssh galaxy \"mkdir -p $remote_dir\""
   ssh galaxy "mkdir -p $remote_dir"
   
   echo "rsync -avP *.metafits galaxy:${remote_dir}/"
   rsync -avP *.metafits galaxy:${remote_dir}/
   
   echo "rsync -avP time*.txt galaxy:${remote_dir}/"
   rsync -avP time*.txt galaxy:${remote_dir}/
else
   echo "WARNING : remote directory not provided -> cannot copy metafits files ..."     
fi
