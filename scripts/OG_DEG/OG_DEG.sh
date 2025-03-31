#!/bin/bash

module load r
source $1

Rscript scripts/OG_DEG/OG_DEG.R $sonicOutput $species $DEGout $transmaps

sstat -j $SLURM_JOB_ID.batch --format=JobID,MaxVMSize
