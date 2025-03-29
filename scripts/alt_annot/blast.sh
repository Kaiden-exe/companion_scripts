#!/bin/bash

module load blast
source $1

# Get right files 
speciesID=$(sed -n "$SLURM_ARRAY_TASK_ID"p $species)
DB=$modelDB/$modelID
QUERY=$proteomes/${speciesID}.fasta

mkdir -p $blastRes/$modelID
blastp -query $QUERY -db $DB -outfmt 6 -out $blastRes/$modelID/${speciesID}.txt -num_threads 8 -evalue 0.001

#Column headers:
##qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore
# 1.  qseqid      query or source (e.g., gene) sequence id
# 2.  sseqid      subject  or target (e.g., reference genome) sequence id
# 3.  pident      percentage of identical matches
# 4.  length      alignment length (sequence overlap)
# 5.  mismatch    number of mismatches
# 6.  gapopen     number of gap openings
# 7.  qstart      start of alignment in query
# 8.  qend        end of alignment in query
# 9.  sstart      start of alignment in subject
#10.  send        end of alignment in subject
#11.  evalue      expect value
#12.  bitscore    bit score

echo "DONE"

sstat -j $SLURM_JOB_ID.batch --format=JobID,MaxVMSize

