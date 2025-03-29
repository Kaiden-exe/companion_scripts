#!/bin/bash

source $1
module load r
makedir -p $output
Rscript --vanilla scripts/alt_annot/model_transfer.R $modelID $modelAnnot $species $blastRes $output