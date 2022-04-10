#!/bin/bash

window="" # e.g. "-w (x_start,y_start)-(x_end,y_end)"
if [[ -n "$1" && "$1" != "-" ]]; then
   window=$1
fi

pol=XX
if [[ -n "$2" && "$2" != "-" ]]; then
   pol="$2"
fi

template="20????????????"
if [[ -n "$3" && "$3" != "-" ]]; then
   template="$3"
fi

fits_file_template=wsclean*-${pol}-dirty.fits
if [[ -n "$4" && "$4" != "-" ]]; then
   fits_file_template="${4}"
fi

outdir_prefix="lc"
if [[ -n "$5" && "$5" != "-" ]]; then
   outdir_prefix="$5"
fi


echo "ls ${template}/${fits_file_template} > ${outdir_prefix}/fits_list_${pol}"
ls ${template}/${fits_file_template} > ${outdir_prefix}/fits_list_${pol}

echo "sbatch pawsey_dump_lc_pixels.sh ${outdir_prefix}/fits_list_${pol} \"${window}\" ${outdir_prefix}_${pol}"
sbatch pawsey_dump_lc_pixels.sh ${outdir_prefix}/fits_list_${pol} "${window}" ${outdir_prefix}_${pol}
