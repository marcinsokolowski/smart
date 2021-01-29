#!/bin/bash -l

#  sbatch -p workq -M $sbatch_cluster pawsey_rms_test.sh FITS_LIST_FILE_NAME X Y 

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
#SBATCH --mem=2gb
#SBATCH --output=./smart_rms_test.o%j
#SBATCH --error=./smart_rms_test.e%j
#SBATCH --export=NONE
source $HOME/smart/bin/$COMP/env

list=fits_list
if [[ -n "$1" && "$1" != "-" ]]; then
   list=$1
fi

x=-1
if [[ -n "$2" && "$2" != "-" ]]; then
  x=$2
fi

y=-1
if [[ -n "$3" && "$3" != "-" ]]; then
  y=$3
fi

radius=50
if [[ -n "$4" && "$4" != "-" ]]; then
  radius=$4
fi


# WARNING : this should realy be later in the code, but need it here to be used in the ls in the next line:
echo "################################"
echo "PARAMETERS:"
echo "################################"
echo "List = $list"
echo "(x,y)  = ($x,$y)"
echo "radius = $radius"
echo "################################"


# echo "---------------------------------------- ~/smart/miriad/miriad_rms.py ----------------------------------------"
# echo "python ~/smart/miriad/miriad_rms.py $list --x=${x} --y=${y} --radius=50"
# python ~/smart/miriad/miriad_rms.py $list --x=${x} --y=${y} --radius=50

echo "---------------------------------------- RMS from other method also for full image ~/smart/bin/calcfits_bg ----------------------------------------"

for fits in `cat $list`
do
   echo "~/smart/bin/calcfits_bg $fits s ${x} ${y} -R ${radius}"
   ~/smart/bin/calcfits_bg $fits s ${x} ${y} -R ${radius}
done   
