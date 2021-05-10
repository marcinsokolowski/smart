#!/bin/bash

obsid=1194350120
if [[ -n "$1" && "$1" != "-" ]]; then
   obsid=$1
else
   echo "ERROR : OBSID must be provided in 1st parameter !!!"
   exit;
fi

calid=1194345816
if [[ -n "$2" && "$2" != "-" ]]; then
   calid=$2
else
   echo "ERROR : CALIBRATION OBSID must be provided in 2nd parameter !!!"
   exit;
fi

object="00h36m08.95s -10d34m00.3s"
# test : J2330 object="23h30m26.9s -20d05m29.63s"
if [[ -n "$3" && "$3" != "-" ]]; then
   object="$3"
else
   echo "ERROR : OBJECT must be provided in 3rd parameter !!!"
   exit;
fi

sleep_time=2
if [[ -n "$4" && "$4" != "-" ]]; then
   sleep_time=$4
fi

file_template="timestamps_?????.txt"
if [[ -n "$5" && "$5" != "-" ]]; then
   file_template=$5
fi

imagesize=2048
if [[ -n "$6" && "$6" != "-" ]]; then
   imagesize=$6
fi

vis_dir=/astro/mwavcs/vcs/${obsid}/vis
if [[ -n "$7" && "$7" != "-" ]]; then
   vis_dir=$7
fi

do_remove=1
if [[ -n "$8" && "$8" != "-" ]]; then
   do_remove=$8
fi   

wsclean_type="standard"
if [[ -n "${9}" && "${9}" != "-" ]]; then
   wsclean_type=${9}
fi

wsclean_pbcorr=0
if [[ -n "${10}" && "${10}" != "-" ]]; then
   wsclean_pbcorr=${10}
fi

n_iter=10000 # 100000 too much 
if [[ -n "${11}" && "${11}" != "-" ]]; then
   n_iter=${11}
fi

wsclean_options=""
if [[ -n "${12}" && "${12}" != "-" ]]; then
   wsclean_options=${12}
fi

queue="workq" # for GPUs use gpuq
if [[ -n "${13}" && "${13}" != "-" ]]; then
   queue=${13}
fi



echo "#####################################################"
echo "PARAMETERS :"
echo "#####################################################"
echo "wsclean_type    = $wsclean_type"
echo "wsclean_pbcorr  = $wsclean_pbcorr"
echo "n_iter          = $n_iter"
echo "wsclean_options = $wsclean_options"
echo "queue           = $queue"
echo "#####################################################"


if [[ -d data || -L data ]]; then
   echo "INFO : data subdirectory / link already exists -> nothing to be done"
else
   # THIS NEEDS TO BE FIXED !!!
   echo "WARNING : data subdirectory does not exist -> creating a link for user = $USER :"
   if [[ $USER == "msok" ]]; then
      if [[ $cluster != "mwa" && $cluster != "garrawarla" ]]; then # mwa = garrawarla
         echo "ln -s /group/mwasci/msok/test/202002/1194350120/J2330/data"
         ln -s /group/mwasci/msok/test/202002/1194350120/J2330/data
      else
         echo "ln -s /astro/mwaops/msok/mwa/smart/data"
         ln -s /astro/mwaops/msok/mwa/smart/data 
      fi
   else
      if [[ $USER == "susmita" && $cluster == "magnus" ]]; then
         echo "DEBUG : user = susmita , cluster = magnus"
         echo "cp -a /astro/mwavcs/susmita/code/mwa_pb/data ."
         cp -a /astro/mwavcs/susmita/code/mwa_pb/data .
      fi
      echo "$USER : ln -s ~/github/mwa_pb/data"
      ln -s ~/github/mwa_pb/data
   fi
fi

mkdir -p TIMESTAMPS_BACKUP/
echo "cp  ${file_template} TIMESTAMPS_BACKUP/"
cp  ${file_template} TIMESTAMPS_BACKUP/

last_file=`ls ${file_template} | tail -1`

for timestep_file in `ls ${file_template}`
do
   # last 1 is to create subdirectories for each timestamp
#   echo "sbatch -p workq -M magnus $SMART_DIR/bin/pawsey/pawsey_smart_cotter_timestep.sh - - - - - \"00h34m21.83s -05d34m36.72s\" - - $timestep_file 1"
#   sbatch -p workq -M magnus $SMART_DIR/bin/pawsey/pawsey_smart_cotter_timestep.sh - - - - - "00h34m21.83s -05d34m36.72s" - - $timestep_file 1

   is_last=0
   if [[ $timestep_file == $last_file ]]; then
      echo "Last file $timestep_file == $last_file -> is_last := 1"
      is_last=1
   fi
   
   # /astro/mwaops/vcs/ -> /astro/mwavcs/vcs/1275085816/vis/
   echo "sbatch -p $queue -M $sbatch_cluster $SMART_DIR/bin/pawsey/pawsey_smart_cotter_timestep.sh - ${do_remove} ${vis_dir} ${obsid} ${calid} \"${object}\" - $imagesize $timestep_file 1 $is_last - ${wsclean_type} ${wsclean_pbcorr} ${n_iter} \"${wsclean_options}\""
   sbatch -p $queue -M $sbatch_cluster $SMART_DIR/bin/pawsey/pawsey_smart_cotter_timestep.sh - ${do_remove} ${vis_dir} ${obsid} ${calid} "${object}" - $imagesize $timestep_file 1 $is_last - ${wsclean_type} ${wsclean_pbcorr} ${n_iter} "${wsclean_options}"

#   echo "mv ${timestep_file} ${timestep_file}.SUBMITTED"
#   mv ${timestep_file} ${timestep_file}.SUBMITTED
   
   echo "sleep $sleep_time"
   sleep $sleep_time
done

# 
# NOT ANYMORE !!! Replaced by automatic submit at last file 
#
# submitting a job to wait until all images are created and average them:
# echo "nohup $SMART_DIR/bin/pawsey//submit_avg_magnus.sh \"${file_template}\" > avg_wait.out 2>&1 "
# nohup $SMART_DIR/bin/pawsey//submit_avg_magnus.sh "${file_template}" > avg_wait.out 2>&1 &
