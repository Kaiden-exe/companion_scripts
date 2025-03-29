# Alternative annotation
# Annotate model if not done already 
if [ ! -f "$modelAnnot/${modelID}.emapper.annotations" ] ; then
	


# Skip making DB if it already exists 
if [ ! -f "$modelDB/${modelID}.pdb" ] ; then
	job6=$(sbatch -J blastp -N 1 -n 6 --mem=16G -o logfiles/blastdb.%A_%a.out -e logfiles/blastdb.%A_%a.error -A tardi_genomic -p fast -t 0-23:00:00 scripts/makedb.sh $configFile)
	jobID6=${job6##* }
	echo "Creating BLASTdb for $modelID job $jobID6"
else
	jobID6=-1
fi

