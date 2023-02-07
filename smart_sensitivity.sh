#!/bin/bash

obsID=1278106408
if [[ -n "$1" && "$1" != "-" ]]; then
   obSID=$1
fi

inttime=1 # in seconds:
if [[ -n "$2" && "$2" != "-" ]]; then
   inttime=$2
fi

options=""
if [[ -n "$3" && "$3" != "-" ]]; then
   options=$3
fi


metafits=${obsID}.metafits

if [[ -s ${metafits} ]]; then
   echo "Metafits file ${metafits} already downloaded"
else 
   echo "getmeta! $obsID"
   getmeta! $obsID
fi

echo "python ~/github/mwa_pb/scripts/mwa_sensitivity.py -c 121 -p all --gps ${obsID}  -m full_EE --metafits=${metafits} --inttime=${inttime} --bandwidth=30720000 ${options}"
python ~/github/mwa_pb/scripts/mwa_sensitivity.py -c 121 -p all --gps ${obsID}  -m full_EE --metafits=${metafits} --inttime=${inttime} --bandwidth=30720000 ${options}
