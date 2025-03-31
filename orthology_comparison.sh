# commandline argument = config file 
configFile=$1

# Run BUSCO analysis
job0=$(sbatch -J busco -N 1 -n 24 -A tardi_genomic --mem=200G -o logfiles/busco.%A_%a.out -e logfiles/busco.%A_%a.error -p fast -t 00-19:00:00 scripts/orthology_comparison/busco.sh $configFile)
jobI0D=${job0##* }
echo "Running BUSCO $jobID0"

# Filter out BUSCO IDs that are present in every species 
job1=$(sbatch -J filter_busco -N 1 --mem=16G -n 8 -o logfiles/filter_busco.%A_%a.out -e logfiles/filter_busco.%A_%a.error -A tardi_genomic -p fast -t 0-23:00:00 --dependency=afterok:$jobID0 scripts/orthology_comparison/busco_filter.sh $configFile)
jobID1=${job1##* }
echo "Filter BUSCO results $jobID1"

# Get IDs per cluster and clusters per ID 
job2=$(sbatch -J busco_analysis -n 16 --mem=16G -t 00-23:00:00 -p fast -A tardi_genomic -o logfiles/busco_analysis.%A.%a.out -e logfiles/busco_analysis.%A.%a.error --dependency=afterok:$jobID1 scripts/orthology_comparison/busco_analysis.sh $configFile)
jobID2=${job2##* }
echo "Analysing BUSCO results $jobID2"

# Visualise IDs per cluster 
job3=$(sbatch -J busco_visualisation -n 16 --mem=16G -t 00-23:00:00 -p fast -A tardi_genomic -o logfiles/busco_analysis.%A.%a.out -e logfiles/busco_analysis.%A.%a.error --dependency=afterok:$jobID2 scripts/orthology_comparison/busco_visualisation.sh)
jobID3=${job3##* }
echo "Visualising results $jobID3"
