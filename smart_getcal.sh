#!/bin/bash

calid=$1

options=""
if [[ -n "$2" && "$2" != "-" ]]; then
   options="$2"
fi

echo "wget \"http://ws.mwatelescope.org/calib/get_calfile_for_calid?cal_id=${calid}\" -O solutions.zip"
wget "http://ws.mwatelescope.org/calib/get_calfile_for_calid?cal_id=${calid}" -O solutions.zip
