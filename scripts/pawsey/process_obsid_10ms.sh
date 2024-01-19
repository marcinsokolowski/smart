#!/bin/bash

#SBATCH --account=mwavcs
#SBATCH --time=23:59:00
#SBATCH --gres=gpu:1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --tasks-per-node=1
#SBATCH --mem=120gb
#SBATCH --output=./cotter_wsclean.o%j
#SBATCH --error=./cotter_wsclean.e%j
#SBATCH --export=NONE

obsid=1274143152
if [[ -n "$1" && "$1" != "-" ]]; then
   obsid=$1
fi

gpstime=1274143154 # specific GPS second to process 
if [[ -n "$2" && "$2" != "-" ]]; then
   gpstime=$2
fi

timestamp=20200522003856
if [[ -n "$3" && "$3" != "-" ]]; then
   timestamp=$3
fi

calid=1274143032   # calibration ID 
if [[ -n "$4" && "$4" != "-" ]]; then
   calid=$4
fi

# for 24 channels set this (5th) parameter to "-channels-out 24"
wsclean_options="-"
if [[ -n "$5" && "$5" != "-" ]]; then
   wsclean_options="$5"
fi

top_ch=132 # highest of 24 MWA coarse channels 
if [[ -n "$6" && "$6" != "-" ]]; then
   top_ch=$6
fi

image_size=2048
if [[ -n "$7" && "$7" != "-" ]]; then
   image_size=$7
fi

# base_datadir=/astro/mwavcs/vcs/
base_datadir=/scratch/mwavcs/msok/data/
if [[ -n "$8" && "$8" != "-" ]]; then
   base_datadir="$8"
fi


echo "#####################################################"
echo "PARAMETERS:"
echo "#####################################################"
echo "obsid = $obsid"
echo "gpstime = $gpstime , timestamp = $timestamp"
echo "calid = $calid"
echo "wsclean_options = $wsclean_options"
echo "Top frequency channel = $top_ch"
echo "image size = $image_size"
echo "base_datadir = $base_datadir"
echo "#####################################################"


# Example script to process obsID = 1274143152 and form 10ms images (averaged over full frequency band) :

pwd

# create metafits for 10ms images:
echo "$SMART_DIR/bin/pawsey/pawsey_smart_prepare_timestamps.sh ${obsid} ${base_datadir}/${obsid}/cal/${obsid}/vis - - - - - - - - 1"
$SMART_DIR/bin/pawsey/pawsey_smart_prepare_timestamps.sh ${obsid} ${base_datadir}/${obsid}/cal/${obsid}/vis - - - - - - - - 1 


# correlation in 10ms time resolution :
echo "$SMART_DIR/bin/pawsey/pawsey_correlate_10ms.sh ${obsid} - ${gpstime} - $top_ch"
$SMART_DIR/bin/pawsey/pawsey_correlate_10ms.sh ${obsid} - ${gpstime} - $top_ch

# get calibration:
echo "~/bin/getcal! ${calid}"
~/bin/getcal! ${calid}

echo "unzip solutions.zip"
unzip solutions.zip

if [[ ! -s ${calid}.bin ]]; then
   echo "ERROR : calibration solution file ${calid}.bin does not exist !"
   exit
fi


# cotter :
echo "cotter -absmem 64 -j 12 -timeres 0.01 -freqres 0.01 -edgewidth 80 -noflagautos  -m ${timestamp}.metafits -noflagmissings -allowmissing -offline-gpubox-format -initflag 0 -full-apply ${calid}.bin -o ${obsid}_${timestamp}.ms ${obsid}_${timestamp}_*gpubox*fits"
cotter -absmem 64 -j 12 -timeres 0.01 -freqres 0.01 -edgewidth 80 -noflagautos  -m ${timestamp}.metafits -noflagmissings -allowmissing -offline-gpubox-format -initflag 0 -full-apply ${calid}.bin -o ${obsid}_${timestamp}.ms ${obsid}_${timestamp}_*gpubox*fits

# WSCLEAN :
echo "$SMART_DIR/bin/pawsey//submit_10ms_dirty_images.sh ${obsid} ${timestamp} \"${wsclean_options}\" $image_size"
$SMART_DIR/bin/pawsey//submit_10ms_dirty_images.sh ${obsid} ${timestamp} "${wsclean_options}" $image_size

cd ${timestamp}
echo "ls wsclean_${obsid}_${timestamp}_briggs_timeindex???-XX-dirty.fits > fits_list_XX"
ls wsclean_${obsid}_${timestamp}_briggs_timeindex???-XX-dirty.fits > fits_list_XX
cnt=`wc -l fits_list_XX | awk '{print $1;}'`
if [[ $cnt -le 0 ]]; then
   echo "ls wsclean_${obsid}_${timestamp}_briggs_timeindex???-????-XX-dirty.fits > fits_list_XX"
   ls wsclean_${obsid}_${timestamp}_briggs_timeindex???-????-XX-dirty.fits > fits_list_XX
fi
cnt=`wc -l fits_list_XX | awk '{print $1;}'`
echo "Number of FITS files to average = $cnt"

echo "avg_images fits_list_XX out.fits out_rms.fits -r 100000 -r 100000"
avg_images fits_list_XX out.fits out_rms.fits -r 100000 -r 100000
