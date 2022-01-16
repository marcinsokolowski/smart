#!/bin/bash -l

#  sbatch -p workq -M $sbatch_cluster pawsey_smart_avg_n_stokes.sh

# Same as ../smart_cotter_image_all.sh , just the SBATCH lines below are added 
# so after update in smart_cotter_image_all.sh please update also this one by :
#    mv pawsey_smart_cotter_timestep.sh pawsey_smart_cotter_timestep.sh.OLD
#    Copy SBATCH lines from pawsey_smart_cotter_timestep.sh.OLD
#    cp ../smart_cotter_image_all.sh pawsey_smart_cotter_timestep.sh
#    Paste SBATCH lines into new version of pawsey_smart_cotter_timestep.sh and add -l in #!/bin/bash -l line 

#SBATCH --account=pawsey0348
#SBATCH --account=mwavcs
#SBATCH --time=23:59:00
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --mem=120gb
#SBATCH --output=./smart_avgnimages.o%j
#SBATCH --error=./smart_avgnimages.e%j
#SBATCH --export=NONE
source $HOME/smart/bin/$COMP/env

list=fits_list_I # `ls *_I.fits |wc -l`
if [[ -n "$1" && "$1" != "-" ]]; then
   list=$1
fi

ra_deg=0.00
if [[ -n "$2" && "$2" != "-" ]]; then
   ra_deg=$2
fi

dec_deg=0.00
if [[ -n "$3" && "$3" != "-" ]]; then
   dec_deg=$3
fi

stokes="I"
if [[ -n "$4" && "$4" != "-" ]]; then
   stokes=$4
fi


echo "################################"
echo "PARAMETERS:"
echo "################################"
echo "fits list file = $list"
echo "(ra,dec) = ($ra,$dec) [deg]"
echo "Stokes = $stokes"
echo "################################"


echo "python $SMART_DIR/bin/dump_pixel_radec.py $list --ra=${ra_deg} --dec=${dec_deg} --radius=2 --calc_rms --outfile=mean_fits_stokes_${stokes}.txt --last_processed_filestamp=${list}_${stokes}.last_processed_file"
python $SMART_DIR/bin/dump_pixel_radec.py $list --ra=${ra_deg} --dec=${dec_deg} --radius=2 --calc_rms --outfile=mean_fits_stokes_${stokes}.txt --last_processed_filestamp=${list}_${stokes}.last_processed_file
