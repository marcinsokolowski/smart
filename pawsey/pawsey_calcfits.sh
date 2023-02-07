#!/bin/bash -l

# Same as ../smart_cotter_image_all.sh , just the SBATCH lines below are added 
# so after update in smart_cotter_image_all.sh please update also this one by :
#    mv pawsey_smart_cotter_timestep.sh pawsey_smart_cotter_timestep.sh.OLD
#    Copy SBATCH lines from pawsey_smart_cotter_timestep.sh.OLD
#    cp ../smart_cotter_image_all.sh pawsey_smart_cotter_timestep.sh
#    Paste SBATCH lines into new version of pawsey_smart_cotter_timestep.sh and add -l in #!/bin/bash -l line 
  
#SBATCH --account=pawsey0348
#SBATCH --time=12:00:00
#SBATCH --nodes=1
#SBATCH --tasks-per-node=8
#SBATCH --mem=16gb
#SBATCH --output=/astro/mwaops/msok/log/smart/stat.o%j
#SBATCH --error=/astro/mwaops/msok/log/smart/stat.e%j
#SBATCH --export=NONE
source /home/msok/smart/bin/magnus/env
  


for fits in `cat fits_list_I`
do
   out=${fits%%fits}stat

   echo "~/smart/bin/calcfits_bg ${fits} s > ${out}"   
   ~/smart/bin/calcfits_bg ${fits} s > ${out}
   cat ${out}
done

