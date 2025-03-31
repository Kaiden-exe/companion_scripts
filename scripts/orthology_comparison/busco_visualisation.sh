#!/bin/bash

module load r

Rscript scripts/orthology_comparison/busco_visualisation.R

sstat -j $SLURM_JOB_ID.batch --format=JobID,MaxVMSize
