#!/bin/bash

metafits=1150234552.metafits

azim=33.6901
alt=64.6934

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
   echo "python $BIGHORNS/software/analysis/scripts/shell/smart/fix_metafits_time_radec.py ${t}.metafits $t_dateobs $t_gps $ra $dec"
   python $BIGHORNS/software/analysis/scripts/shell/smart/fix_metafits_time_radec.py ${t}.metafits $t_dateobs $t_gps $ra $dec
   
   
done < timestamps100.txt
