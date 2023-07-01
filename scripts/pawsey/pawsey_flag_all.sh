#!/bin/bash

for file in `ls all_?????.txt`
do
   echo "sbatch ./pawsey_casa.sh $file"
   sbatch ./pawsey_casa.sh $file   
done
