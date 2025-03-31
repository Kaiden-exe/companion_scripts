#!/bin/bash

module load r
source $1

# Merge tables
commonID=$filteredTables/All_common_IDs.tsv
cat $filtered_tables/*_common.tsv > $commonID

Rscript --vanilla busco_analysis.R $commonID $orthologerFile $sonicparanoidFile $orthofinderFile

sstat -j $SLURM_JOB_ID.batch --format=JobID,MaxVMSize
