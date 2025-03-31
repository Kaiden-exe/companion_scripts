#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
# 1st argument = ortholog_groups.tsv
# 2nd = species.txt
# 3rd = DEGout
# 4th = transmaps

###### Libraries ######
library(tidyr)
library(dplyr)

###### Import ######
OGs = read.delim(args[1], comment.char="#", na.strings="*")
colnames(OGs) = gsub(".fasta", "", colnames(OGs))

species = read.table(args[2])
species = as.vector(species[,1])

genes = as.data.frame(OGs$group_id)
colnames(genes) = c('group_id')
FCs = as.data.frame(OGs$group_id)
colnames(FCs) = c('group_id')

for (species in allSpecies) {
  # Get right files 
  degs = read.delim(paste(args[3], species, "_DESeq_results.txt", sep = ""))
  transMap = read.delim(paste(args[4], species, ".gene_trans_map",
                              sep = ""), header = F)
  colnames(transMap) = c('geneID', 'proteinID')
  
  # Get proteins in OGs
  OGss = OGs[,c('group_id', species)]
  OGss = na.omit(OGss)
  OGss = separate_rows(OGss, matches(species), sep=",")
  colnames(OGss) = c('group_id', 'proteinID')
  
  if (species == 'Pfai') {
    OGss$proteinID = gsub('\\.p.', '', OGss$proteinID)
  }
  
  # Filter proteins to genes
  df = merge(OGss, transMap)
  df = distinct(df, group_id, geneID, .keep_all = T)
  
  # Add DEG info
  df = merge(df, degs)
  
  # Get highest expressed gene per OG
  df = df %>% group_by(group_id) %>% filter(log2FoldChange == max(log2FoldChange))

  # Genes 
  df_gene = df[, c('group_id', 'geneID')]
  colnames(df_gene) = c('group_id', species)
  genes = merge(genes, df_gene, all.x = T)
  
  # FCs
  df_fc = df[, c('group_id', 'log2FoldChange')]
  colnames(df_fc) = c('group_id', species)
  FCs = merge(FCs, df_fc, all.x = T)
}


FCs$min = apply(FCs[,allSpecies], 1, FUN = min, na.rm =T)
FCs$max = apply(FCs[,allSpecies], 1, FUN = max, na.rm =T)
FCs$mean = apply(FCs[,allSpecies], 1, FUN = mean, na.rm =T)
FCs$median = apply(FCs[,allSpecies], 1, FUN = median, na.rm =T)

# Clean up 
FCs = FCs[!is.na(FCs$median),]
genes = genes[genes$group_id %in% FCs$group_id,]

write.table(genes, file="maxlog2FC_genes.tsv", quote=F, sep="\t",row.names = F)
write.table(FCs, file="maxlog2FC_FCs.tsv", quote=F, sep="\t",row.names = F)
