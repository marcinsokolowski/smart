#!/bin/bash

n_images_per_job=100
if [[ -n "$1" && "$1" != "-" ]]; then
   n_images_per_job=$1
fi

timesteps_file=timesteps.txt
if [[ -n "$2" && "$2" != "-" ]]; then
   timesteps_file=$2
fi


n_timestemps=`cat $timesteps_file | wc -l`
n_jobs=`echo "$n_images_per_job $n_timestemps" | awk '{print $2/$1;}'`

echo "##############################################"
echo "PARAMETERS:"
echo "##############################################"
echo "timesteps_file = $timesteps_file"
echo "n_timestemps   = $n_timestemps"
echo "n_jobs         = $n_jobs"
echo "##############################################"

