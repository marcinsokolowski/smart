#!/bin/bash

template="*.fits"
if [[ -n "$1" && "$1" != "-" ]]; then
   template=$1
fi

freq_cc=121
if [[ -n "$2" && "$2" != "-" ]]; then
   freq_cc=$2
fi

ls ${template} | grep -v CorrFlux > save_list

for fits in `ls ${template} | grep -v CorrFlux`
do
   if [[ $fits == "mean_stokes_I.fits" ]]; then
      # include flux calibration of all images :
      echo "smart_gleam_flux_scale.sh $fits $freq_cc save_list"
      smart_gleam_flux_scale.sh $fits $freq_cc save_list
   else
      echo "smart_gleam_flux_scale.sh $fits $freq_cc"
      smart_gleam_flux_scale.sh $fits $freq_cc
   fi
done
