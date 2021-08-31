#!/bin/bash -l

#SBATCH --account=mwavcs
#SBATCH --time=23:59:00
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-gpu=1
#SBATCH --mem=60gb
#SBATCH --output=./pawsey_submit_any.o%j
#SBATCH --error=./pawsey_submit_any.e%j
#SBATCH --export=NONE
echo "source $HOME/smart/bin/$COMP/env"
source $HOME/smart/bin/$COMP/env

command_line=$1


echo "$command_line"
$command_line

