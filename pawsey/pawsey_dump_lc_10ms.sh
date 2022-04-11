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
outdir=${outdir_prefix}_${pol}


mkdir -p ${outdir}

pwd
# echo "ls ${template}/${fits_file_template} > ${outdir}/fits_list_${outdir_prefix}_${pol}"
# ls ${template}/${fits_file_template} > ${outdir}/fits_list_${outdir_prefix}_${pol}

# find 20???????????? -name "wsclean*-I-dirty.fits"|sort
echo "find ${template} -name ${fits_file_template} | sort > ${outdir}/fits_list_${outdir_prefix}_${pol}"
find ${template} -name ${fits_file_template} | sort > ${outdir}/fits_list_${outdir_prefix}_${pol}

pwd
echo "sbatch pawsey_dump_lc_pixels.sh ${outdir}/fits_list_${outdir_prefix}_${pol} \"${window}\" ${outdir}"
sbatch pawsey_dump_lc_pixels.sh ${outdir}/fits_list_${outdir_prefix}_${pol} "${window}" ${outdir}
