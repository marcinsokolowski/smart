#!/bin/bash

frame=icrs
if [[ -n "$1" && "$1" != "-" ]]; then
   frame=$1
fi

ux=`date +%s`
echo "ux = $ux"

rm -f old.txt new.txt

alt=0
while [[ alt -le 90 ]];
do
   az=0
   while [[ az -lt 360 ]];
   do
      echo "azh2radec $ux mwa $az $alt >> old.txt"
      azh2radec $ux mwa $az $alt >> old.txt
      
      echo "python ./azh2radec.py $ux mwa $az $alt $frame >> new.txt"
      python ./azh2radec.py $ux mwa $az $alt $frame >> new.txt
      
      if [[ $alt == 90 ]]; then
         az=360
      fi
      az=$(($az+1))
   done
      
   alt=$(($alt+1))
done
