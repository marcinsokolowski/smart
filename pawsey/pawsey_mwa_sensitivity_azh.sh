#!/bin/bash -l

# Same as ../smart_cotter_image_all.sh , just the SBATCH lines below are added 
# so after update in smart_cotter_image_all.sh please update also this one by :
#    mv pawsey_smart_cotter_timestep.sh pawsey_smart_cotter_timestep.sh.OLD
#    Copy SBATCH lines from pawsey_smart_cotter_timestep.sh.OLD
#    cp ../smart_cotter_image_all.sh pawsey_smart_cotter_timestep.sh
#    Paste SBATCH lines into new version of pawsey_smart_cotter_timestep.sh and add -l in #!/bin/bash -l line 

#SBATCH --account=pawsey0348
#SBATCH --account=mwavcs
#SBATCH --time=01:00:00
#SBATCH --nodes=1
#SBATCH --tasks-per-node=8
#SBATCH --mem=20gb
#SBATCH --output=./pawsey_mwa_sensitivity_azh.o%j
#SBATCH --error=./pawsey_mwa_sensitivity_azh.e%j
#SBATCH --export=NONE
source $HOME/smart/bin/$COMP/env
module load skyfield

obsid=1276622116
if [[ -n "$1" && "$1" != "-" ]]; then
   obsid=$1
fi

az=341.6
if [[ -n "$2" && "$2" != "-" ]]; then
   az=$2
fi

za=22
if [[ -n "$3" && "$3" != "-" ]]; then
   za=$3
fi

freq_cc=145
if [[ -n "$4" && "$4" != "-" ]]; then
   freq_cc=$4   
fi

gpstime=$obsid
if [[ -n "$5" && "$5" != "-" ]]; then
   gpstime=$5
fi

echo "##########################################################################"
echo "PARAMETERS :"
echo "##########################################################################"
echo "obsid = $obsid"
echo "(az,za) = ($az,$za) [deg]"
echo "Frequency channel = $freq_cc"
echo "gpstime = $gpstime"
echo "##########################################################################"


pwd
if [[ ! -s ${obsid}.metafits ]]; then
   url="http://ws.mwatelescope.org/metadata/fits?obs_id="
   echo "wget ${url}${obsid} -O ${obsid}.metafits"
   wget ${url}${obsid} -O ${obsid}.metafits
else
   echo "INFO : metafits file ${obsid}.metafits already exists"
fi

echo "python ~/github/mwa_pb/scripts/mwa_sensitivity.py -g ${gpstime} -m full_EE --freq_cc ${freq_cc} --metafits ${obsid}.metafits --inttime=1 --bandwidth=30720000 --pointing_az_deg=${az} --pointing_za_deg=${za}"
python ~/github/mwa_pb/scripts/mwa_sensitivity.py -g ${gpstime} -m full_EE --freq_cc ${freq_cc} --metafits ${obsid}.metafits --inttime=1 --bandwidth=30720000 --pointing_az_deg=${az} --pointing_za_deg=${za}
