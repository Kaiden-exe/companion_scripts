#!/bin/bash

source $1

module load singularity

apptainer exec --bind $DIR $DIR/bin/busco_v5.8.2_cv1.sif busco -i $pepDir -l metazoa_odb10 -m proteins --tar --cpu 24 -o metazoa_busco

for pepFile in $pepDir/*.pep; do
	species=$(basename $pepFile .pep)
	dirName=$(basename $pepFile)
	buscoRes=metazoa_busco/$dirName/run_metazoa_odb10/full_table.tsv
	sed '/Missing/d' $buscoRes > $filteredTables/${species}_busco.tsv
done

echo "DONE"

sstat -j $SLURM_JOB_ID.batch --format=JobID,MaxVMSize






