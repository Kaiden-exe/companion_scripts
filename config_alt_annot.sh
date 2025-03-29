# Alternative annotation
# run: bash alt_annot.sh config.sh

# SpeciesIDs, proteome files must be named speciesID.fasta
species=species.txt

# Directory where speciesID.fasta is located
proteomes=proteins

# ID for the model species 
modelID=Cele

# Proteome of your model species 
proteomeFile=Cele_proteome.fasta

# Location eggnog database
DAT=/shared/bank/emapperdb/5.0.2

# Output locations 
modelDB=CeleDB
modelAnnot=Cele_annot
blastRes=BLAST_results
output=transferred_annotation