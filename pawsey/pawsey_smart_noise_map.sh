#!/bin/bash -l

#  sbatch -p workq -M $sbatch_cluster ~/smart/bin/pawsey/pawsey_smart_noise_map.sh mean_stokes_I.fits
#
# Same as ../smart_cotter_image_all.sh , just the SBATCH lines below are added 
# so after update in smart_cotter_image_all.sh please update also this one by :
#    mv pawsey_smart_cotter_timestep.sh pawsey_smart_cotter_timestep.sh.OLD
#    Copy SBATCH lines from pawsey_smart_cotter_timestep.sh.OLD
#    cp ../smart_cotter_image_all.sh pawsey_smart_cotter_timestep.sh
#    Paste SBATCH lines into new version of pawsey_smart_cotter_timestep.sh and add -l in #!/bin/bash -l line 

#SBATCH --account=mwavcs
#SBATCH --time=23:59:00
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-gpu=1
#SBATCH --mem=120gb
#SBATCH --output=./smart_noisemap.o%j
#SBATCH --error=./smart_noisemap.e%j
#SBATCH --export=NONE
source $HOME/smart/bin/$COMP/env

fits=aaa.fits
if [[ -n "$1" && "$1" != "-" ]]; then
   fits=$1
fi

rms_radius=10
if [[ -n "$2" && "$2" != "-" ]]; then
   rms_radius=$2
fi

fits_base_tmp=${fits%%.fits}
fits_base=`basename $fits_base_tmp`
if [[ -n "$3" && "$3" != "-" ]]; then
   fits_base=$3
fi

outdir="./"
if [[ -n "$4" && "$4" != "-" ]]; then
   outdir=$4
fi

options=""
if [[ -n "$5" && "$5" != "-" ]]; then
   options=$5
fi

echo "$srun_command noise_mapper $fits -r ${rms_radius} -i -o ${outdir}/${fits_base} ${options}"
$srun_command noise_mapper $fits -r ${rms_radius} -i -o ${outdir}/${fits_base} ${options}
