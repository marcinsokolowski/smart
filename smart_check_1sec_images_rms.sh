#!/bin/bash

for stokes in `echo "I Q U V"`
do
   avg_file="avg_${stokes}.out"
   rmsiqr_file=rmsiqr_${stokes}.out
   
   grep CENTER $avg_file | awk '{print $1" "$24;}' | grep -v FINA > $rmsiqr_file
   
   root -l "histofile.C(\"${rmsiqr_file}\",1,1)"
done

