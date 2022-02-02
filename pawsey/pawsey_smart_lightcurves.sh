#!/bin/bash -l

#  sbatch -p workq -M $sbatch_cluster pawsey_smart_lightcurves.sh LIST_OF_FITS_FILE LIST_OF_SOURCES STOKES_POLARISATION[default I]
#  
#  LIST_OF_SOURCES in text format with columns : NAME RA[deg] DEC[deg]
#

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
#SBATCH --output=./pawsey_smart_lightcurves.o%j
#SBATCH --error=./pawsey_smart_lightcurves.e%j
#SBATCH --export=NONE
source $HOME/smart/bin/$COMP/env

list=fits_list_I # `ls *_I.fits |wc -l`
if [[ -n "$1" && "$1" != "-" ]]; then
   list=$1
fi

source_list=sources.txt # format NAME RA[deg] DEC[deg]
if [[ -n "$2" && "$2" != "-" ]]; then
   source_list=$2
fi

stokes="I"
if [[ -n "$3" && "$3" != "-" ]]; then
   stokes=$3
fi

outnametag=mean_fits_stokes
if [[ -n "$4" && "$4" != "-" ]]; then
   outnametag=$4
fi


echo "################################"
echo "PARAMETERS:"
echo "################################"
echo "fits list file = $list"
echo "source list    = $source_list"
echo "Stokes         = $stokes"
echo "outnametag     = $outnametag"
echo "################################"

while read line
do
   echo
   echo "Processing line |$line|"
   name=`echo $line | awk '{print $1;}'`
   ra_deg=`echo $line | awk '{print $2;}'`
   dec_deg=`echo $line | awk '{print $3;}'`
   
   echo
   echo
   echo "Generating lightcurve for source $name at (ra,dec) = ($ra_deg,$dec_deg) [deg]"
   date

   # this file needs to be removed to repeat the script, otherwise it will decide that the lightcurve has already been generated
   echo "rm -f ${list}_${stokes}.last_processed_file"
   rm -f ${list}_${stokes}.last_processed_file

   echo "python $SMART_DIR/bin/dump_pixel_radec.py $list --ra=${ra_deg} --dec=${dec_deg} --radius=2 --calc_rms --outfile=${name}_${outnametag}_${stokes}.txt --last_processed_filestamp=${list}_${stokes}.last_processed_file"
   python $SMART_DIR/bin/dump_pixel_radec.py $list --ra=${ra_deg} --dec=${dec_deg} --radius=2 --calc_rms --outfile=${name}_${outnametag}_${stokes}.txt --last_processed_filestamp=${list}_${stokes}.last_processed_file
done <  ${source_list}

