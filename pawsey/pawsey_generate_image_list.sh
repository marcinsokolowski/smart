#!/bin/bash

# (12.14 - 4.02 - 6*1.306)*100 = 28.400 ~= 28 
# see ./pulse_time_index.py
start_timeindex=28.4
if [[ -n "$1" && "$1" != "-" ]]; then
   start_timeindex=$1
fi

outfile="avg.list"
if [[ -n "$2" && "$2" != "-" ]]; then
   outfile=$2
fi

# cd /home/msok/Desktop/MWA/logbook/Ramesh_SMART/data/1274143152/dynamic_spectra
dispersion_sweep_file=dispersed_path_dm20.870.txt
obsid=1274143152

rm -f ${outfile}


pulse_arrival_index=$start_timeindex

last_time_index=6000

period=1.306
period_10ms=131 # in 10ms steps 

n=0
while [[ n -lt 70 ]];
do
   echo
   pulse_arrival_index=`echo $start_timeindex" "$n" "$period_10ms | awk '{idx=$1+$2*$3;printf("%d",idx);}'`
   echo "Pulse n = $n arrives at timeindex = $pulse_arrival_index at channel 24 "
#   sleep 5
   
   while read line
   do
      t_idx=`echo $line | awk '{print $1;}'`
      ch=`echo $line | awk '{print $2;}'`
      
      time_index=$(($pulse_arrival_index + $t_idx))
      subdir=`echo $time_index | awk '{printf("wsclean_timeindex%04d",$1);}'`
      
      # wsclean_1274143152_timeindex1218-0000-I-dirty.fits
      fits_file=`echo "$obsid $time_index $ch" | awk '{printf("wsclean_%d_timeindex%04d-%04d-I-dirty.fits",$1,$2,$3);}'`
      
      if [[ $time_index -lt $last_time_index ]]; then
         echo "$subdir/$fits_file" >> ${outfile}
      else
         echo "WARNING : $subdir/$fits_file skipped"
         exit;
      fi
      
   done < $dispersion_sweep_file
   
   n=$(($n+1))
done

