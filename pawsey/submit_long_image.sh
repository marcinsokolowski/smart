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


if [[ -d data || -L data ]]; then
   echo "INFO : data subdirectory / link already exists -> nothing to be done"
else
   echo "WARNING : data subdirectory does not exist -> creating a link:"
   echo "ln -s /group/mwasci/msok/test/202002/1194350120/J2330/data"
   ln -s /group/mwasci/msok/test/202002/1194350120/J2330/data
fi


for timestamp_file in `ls ${timestamp_template}`
do
   echo "sbatch -p workq -M magnus $SMART_DIR/bin/pawsey/pawsey_smart_cotter_image_list.sh - - /astro/mwavcs/vcs/${obsid}/vis ${obsid} ${calid} "${object}" - $imagesize $timestamp_file 1 0"
   sbatch -p workq -M magnus $SMART_DIR/bin/pawsey/pawsey_smart_cotter_image_list.sh - - /astro/mwavcs/vcs/${obsid}/vis ${obsid} ${calid} "${object}" - $imagesize $timestamp_file 1 0
   
   sleep 5
done
   

