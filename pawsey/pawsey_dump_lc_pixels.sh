#!/bin/bash -l

#  sbatch -p workq -M $sbatch_cluster pawsey_dump_lc_pixels.sh

# dumps lightcurves for all pixels in a specified window or all pixels (if not specified)

#SBATCH --account=mwavcs
#SBATCH --time=23:59:00
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --mem=350gb
#SBATCH --output=./smart_dump_lc_pixels.o%j
#SBATCH --error=./smart_dump_lc_pixels.e%j
#SBATCH --export=NONE

if [[ -s $HOME/smart/bin/$COMP/env ]]; then
   source $HOME/smart/bin/$COMP/env
else
   echo "WARNING : environment file not found ($HOME/smart/bin/$COMP/env)"
fi   

list=fits_list_I # `ls *_I.fits |wc -l`
if [[ -n "$1" && "$1" != "-" ]]; then
   list=$1
fi

window="" # e.g. "-w (x_start,y_start)-(x_end,y_end)"
if [[ -n "$2" && "$2" != "-" ]]; then
   window=$2
fi

outdir="lc/"
if [[ -n "$3" && "$3" != "-" ]]; then
   outdir="$3"
fi


echo "################################"
echo "PARAMETERS:"
echo "################################"
echo "fits list file = $list"
echo "window = $window"
echo "outdir = $outdir"
echo "################################"

date
echo "srun dump_lc $list $window -o $outdir"
srun dump_lc $list $window -o $outdir
date
