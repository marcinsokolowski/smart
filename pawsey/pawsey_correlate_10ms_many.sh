#!/bin/bash

obsid=1274143152
if [[ -n "$1" && "$1" != "-" ]]; then
   obsid=$1
fi

calid=1274143032
if [[ -n "$2" && "$2" != "-" ]]; then
   calid=$2
fi

gpstime=$(($obsid+2))
if [[ -n "$3" && "$3" != "-" ]]; then
   gpstime=$3
fi
uxtime=$(($gpstime+315964782))

duration=600
if [[ -n "$4" && "$4" != "-" ]]; then
   duration=$4
fi
end_gpstime=$(($gpstime+$duration))

seconds_per_job=20
if [[ -n "$5" && "$5" != "-" ]]; then
   seconds_per_job=$5
fi

start_ch=132
if [[ -n "$6" && "$6" != "-" ]]; then
   start_ch=$6
fi


echo "#################################"
echo "PARAMETERS:"
echo "#################################"
echo "obsid = $obsid"
echo "gpstime = $gpstime -> uxtime = $uxtime"
echo "duration = $duration"
echo "end gps = $end_gpstime"
echo "duration = $duration"
echo "calid = $calid"
echo "seconds_per_job = $seconds_per_job"
echo "start_ch = $start_ch"
echo "#################################"

source /astro/mwavcs/msok/blink/cotter_wsclean/env/garrawarla.env

gps=$gpstime
while [[ $gps -le $end_gpstime ]];
do
   echo "sbatch -p gpuq -M $sbatch_cluster ./pawsey_correlate_10ms.sh ${obsid} ${calid} ${gps} ${seconds_per_job} ${start_ch}"
   sbatch -p gpuq -M $sbatch_cluster ./pawsey_correlate_10ms.sh ${obsid} ${calid} ${gps} ${seconds_per_job} ${start_ch}
   
   gps=$(($gps+$seconds_per_job))
done
