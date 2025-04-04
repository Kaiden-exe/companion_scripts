#!/bin/bash

module load r
source $1

Rscript scripts/orthology_comparison/busco_filter.R $filteredTables

sstat -j $SLURM_JOB_ID.batch --format=JobID,MaxVMSize
