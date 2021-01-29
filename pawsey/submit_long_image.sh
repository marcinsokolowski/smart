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

timestamp_template="timestamps_?????.txt"
if [[ -n "$4" && "$4" != "-" ]]; then
   timestamp_template=$4
fi

imagesize=2048
if [[ -n "$5" && "$5" != "-" ]]; then
   imagesize=$5
fi


# parameter $6
# $6 not yet used 

galaxy_path="/astro/mwaops/vcs/${obsid}/vis"
if [[ -n "$7" && "$7" != "-" ]]; then # SHOULD REALLY BE EARLIER BUT IS HERE TO BE ABLE TO USE DEFAULT LOCATION :
   galaxy_path=$7
fi

wsclean_type="standard"
if [[ -n "$8" && "$8" != "-" ]]; then
   wsclean_type=$8
fi

wsclean_pbcorr=0
if [[ -n "${9}" && "${9}" != "-" ]]; then
   wsclean_pbcorr=${9}
fi

n_iter=10000 # 100000 too much 
if [[ -n "${10}" && "${10}" != "-" ]]; then
   n_iter=${10}
fi


if [[ -d data || -L data ]]; then
   echo "INFO : data subdirectory / link already exists -> nothing to be done"
else
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
      echo "$USER : ln -s ~/github/mwa_pb/data"
      ln -s ~/github/mwa_pb/data
   fi
fi

last_file=`ls ${timestamp_template} | tail -1`

for timestamp_file in `ls ${timestamp_template}`
do
   is_last=0
   if [[ $timestep_file == $last_file ]]; then
      echo "Last file $timestep_file == $last_file -> is_last := 1"
      is_last=1
   fi

   echo "sbatch -p workq -M $sbatch_cluster $SMART_DIR/bin/pawsey/pawsey_smart_cotter_image_list.sh - - ${galaxy_path} ${obsid} ${calid} "${object}" - $imagesize $timestamp_file 1 $is_last - ${wsclean_type} ${wsclean_pbcorr} ${n_iter}"
   sbatch -p workq -M $sbatch_cluster $SMART_DIR/bin/pawsey/pawsey_smart_cotter_image_list.sh - - ${galaxy_path} ${obsid} ${calid} "${object}" - $imagesize $timestamp_file 1 $is_last - ${wsclean_type} ${wsclean_pbcorr} ${n_iter}
      
   sleep 5
done
   

