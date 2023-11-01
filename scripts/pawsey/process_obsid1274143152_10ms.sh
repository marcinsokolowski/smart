#!/bin/bash

obsid=1274143152
gpstime=1274143154 # specific GPS second to process 
calid=1274143032   # calibration ID 
timestamp=20200522003856

# Example script to process obsID = 1274143152 and form 10ms images (averaged over full frequency band) :

pwd

# create metafits for 10ms images:
echo "$SMART_DIR/bin/pawsey/pawsey_smart_prepare_timestamps.sh ${obsid} /astro/mwavcs/vcs/${obsid}/cal/${obsid}/vis - - - - - - - - 1"
$SMART_DIR/bin/pawsey/pawsey_smart_prepare_timestamps.sh ${obsid} /astro/mwavcs/vcs/${obsid}/cal/${obsid}/vis - - - - - - - - 1 


# correlation in 10ms time resolution :
echo "$SMART_DIR/bin/pawsey/pawsey_correlate_10ms.sh ${obsid} - ${gpstime}"
$SMART_DIR/bin/pawsey/pawsey_correlate_10ms.sh ${obsid} - ${gpstime}

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
echo "$SMART_DIR/bin/pawsey//submit_10ms_dirty_images.sh ${obsid} ${timestamp} - 2048"
$SMART_DIR/bin/pawsey//submit_10ms_dirty_images.sh ${obsid} ${timestamp} - 2048