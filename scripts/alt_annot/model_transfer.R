#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
# 1st argument = modelID
# 2nd = modelAnnot
# 3rd = species.txt
# 4th = blastRes
# 5th = output 

library(stringr)
library(dplyr)
library(tidyr)

model_annot = read.delim(paste(args[2], "/", args[1], ".emapper.annotations", sep=""),
                          header=FALSE, comment.char="#", na.strings = "-")
colnames(model_annot) = c('query','seed_ortholog','evalue','score',
                        'eggNOG_OGs','max_annot_lvl','COG_category',
                        'Description','Preferred_name','GOs','EC','KEGG_ko',
                        'KEGG_Pathway','KEGG_Module','KEGG_Reaction',
                        'KEGG_rclass','BRITE','KEGG_TC','CAZy',
                        'BiGG_Reaction','PFAMs')
model_annot = model_annot[!is.na(model_annot$GOs),]
model_annot$blastID = str_match(model_annot$query, "\\|(.*?)\\|")[,2]

write.table(model_annot, file=paste(args[2], '/', args[1], "_annot.tsv", sep=""),
            sep="\t", quote = F, row.names = F)

species = read.table(args[3])
species = as.vector(species[,1])

TERM2GENE = NULL
genes = NULL

for (species in allSpecies) { 
  #### IMPORT DATA ####
  # filter blast results 
  blast = read.delim(paste(args[4], species, ".txt", sep=""), header=FALSE)
  colnames(blast) = c('qseqid','sseqid','pident','length','mismatch','gapopen',
                      'qstart','qend','sstart','send','evalue','bitscore')
  
  if (species == "Pfai") {
    blast$qseqid = gsub("\\.p.*", "", blast$qseqid)
  }
  
  blast = group_by(blast, qseqid)
  blast = filter(blast, evalue == min(evalue, na.rm=TRUE))

  # Attach annotation 
  df = merge(blast, model_annot, by.x = 'sseqid', by.y = "blastID")
  
  write.table(df, file=paste(args[5], "/", species, "_annot.tsv", sep=""), row.names=F,
  quote = F, sep='\t')

}
