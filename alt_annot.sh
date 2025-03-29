# Alternative annotation
configFile=$1
# Get amount of species to annotate 
ARRAY_NUM=$(cat $species | wc -l)

# Annotate model if not done already 
if [ ! -f "$modelAnnot/${modelID}.emapper.annotations" ] ; then
	job0=$(sbatch -J annot_model -n 24 --mem=250G -o logfiles/emapper.%A_%a.out -e logfiles/emapper.%A_%a.error -A tardi_genomic -p fast -t 0-23:00:00 scripts/alt_annot/annot_model.sh $configFile)
	jobID0=${job0##* }
	echo "Annotating model $jobID0"
else
	jobID0=-1
fi

# Skip making DB if it already exists 
if [ ! -f "$modelDB/${modelID}.pdb" ] ; then
	job1=$(sbatch -J blastp -N 1 -n 6 --mem=16G -o logfiles/blastdb.%A_%a.out -e logfiles/blastdb.%A_%a.error -A tardi_genomic -p fast -t 0-23:00:00 scripts/alt_annot/makedb.sh $configFile)
	jobID1=${job1##* }
	echo "Creating BLASTdb for $modelID job $jobID1"
else
	jobID1=-1
fi

# BLAST proteomes 
job2=$(sbatch -J BLAST --cpus-per-task=8 --mem-per-cpu=5G -o logfiles/blastp.%A_%a.out -e logfiles/blastp.%A_%a.error -A tardi_genomic -p fast -t 0-23:00:00 --array=1-$ARRAY_NUM --dependency=afterok:${jobID1} scripts/alt_annot/blast.sh $configFile )
job2ID=${job2##* }
