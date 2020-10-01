#!/bin/bash

template="*.fits"
if [[ -n "$1" && "$1" != "-" ]]; then
   template="$1"
fi

x_c=-1
if [[ -n "$2" && "$2" != "-" ]]; then
   x_c="$2"
fi


y_c=-1
if [[ -n "$3" && "$3" != "-" ]]; then
   y_c="$3"
fi

radius=10
if [[ -n "$4" && "$4" != "-" ]]; then
   radius=$4
fi

export PATH=/opt/caastro/ext/anaconda3/bin/:$PATH

ls ${template} > fits_list

path=`which miriad_rms.py`

echo "python $path fits_list --radius=${radius} --x=${x_c} --y=${y_c} > rms.out 2>&1"
python $path fits_list --radius=${radius} --x=${x_c} --y=${y_c} > rms.out 2>&1

for fits in `cat fits_list`
do
   stat=${fits%%fits}stat
   
   echo "calcfits_bg $fits s > $stat"
   calcfits_bg $fits s > $stat
done

cat rms.txt
