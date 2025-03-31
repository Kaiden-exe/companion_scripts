#!/bin/bash

module load r

Rscript busco_visualisation.R

sstat -j $SLURM_JOB_ID.batch --format=JobID,MaxVMSize
