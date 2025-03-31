# Creates two tables
# 1. Highest expressed gene per species cluster
# 2. The Log2FC of said gene 

configFile=$1

sbatch -J OG_DEG -n 8 --mem=16G -t 00-23:00:00 -p fast -A tardi_genomic -o logfiles/OG_DEG.%A.%a.out -e logfiles/OG_DEG.%A.%a.error scrips/OG_DEG/OG_DEG.sh $configFile