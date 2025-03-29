#!/bin/bash

# Author: Kaiden R. Sewradj
# Last update: 28/03/2025

module load eggnog-mapper/2.1.12
source $1

emapper.py -i $proteomeFile --itype proteins -o $modelAnnot --cpu 24 --data_dir $DAT --sensmode ultra-sensitive --override

echo "DONE"

sstat -j $SLURM_JOB_ID.batch --format=JobID,MaxVMSize