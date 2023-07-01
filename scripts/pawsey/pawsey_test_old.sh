#!/bin/bash

source $HOME/smart/bin/magnus/env

if [[ ! -s test.txt ]]; then
   head -1 timestamps.txt > test.txt
fi

# Test : RAJ             23:30:26.885                  7.000e-03 ,  DECJ            -20:05:29.63                  1.700e-01a
# candidate : "00h36m08.95s -10d34m00.3s"
# sbatch -p workq -M magnus ~/smart/bin/pawsey/pawsey_smart_cotter_timestep.sh 1 0 /astro/mwaops/vcs/1194350120/vis 1194350120 1194345816 "23h30m26.9s -20d05m29.63s" - - test.txt 1
sbatch -p workq -M magnus ~/smart/bin/pawsey/pawsey_smart_cotter_timestep.sh 1 0 /astro/mwavcs/vcs/1194350120/vis 1194350120 1194345816 "00h36m08.95s -10d34m00.3s" - - test.txt 1
# lsq
# sbatch -p workq -M magnus ~/smart/bin/pawsey/pawsey_smart_cotter_timestep.sh
