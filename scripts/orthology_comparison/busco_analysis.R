#!/usr/bin/env Rscript
library(dplyr)
library(tidyr)
args = commandArgs(trailingOnly=TRUE)
# 1st = All_common_IDs.tsv
# 2nd = orthologer file
# 3rd = sonic paranoid file
# 4th = orthofinder file


###### IMPORT DATA ######
busco = read.table(args[1], sep = '\t')
colnames(busco) = c('Busco_id',	'Status',	'genes',	'Score',	'Length',
                    'OrthoDB_url',	'Description')
busco = busco[,c('Busco_id', 'genes')]
  
orthologerFile = read.table(args[2], quote="\"")
colnames(orthologerFile) = c('orthologer_cluster', 'genes', 'type', 'seq_len', 
                         'seq_start', 'seq_end', 'pid', 'score', 'evalue')

sonicFile = read.delim(args[3], comment.char="#", na.strings="*")

orthofinderFile = read.delim(args[4], na.strings="")


###### REFORMAT ######
# Sonicparanoid
sonicReduced = sonicFile[,-c(2:4)]
sonicReformat = NULL
for (species in colnames(sonicReduced)[-1]) {
  geneTable = sonicReduced[,c("group_id",species)]
  df <- geneTable %>% 
    mutate(genes=strsplit(geneTable[,c(species)], ",")) %>%
    unnest(genes)
  df[,c(species)] = NULL
  
  if (is.null(sonicReformat)) {
    sonicReformat = df
  } else {
    sonicReformat = rbind(sonicReformat, df)
  }
}

colnames(sonicReformat)[colnames(sonicReformat) == "group_id"] = 'sonic_cluster'

# Orthofinder 
orthofinderReformat = NULL
for (species in colnames(orthofinderFile)[-1]) {
  geneTable = orthofinderFile[,c("Orthogroup",species)]
  df <- geneTable %>% 
    mutate(genes=strsplit(geneTable[,c(species)], ", ")) %>%
    unnest(genes)
  df[,c(species)] = NULL
  
  if (is.null(orthofinderReformat)) {
    orthofinderReformat = df
  } else {
    orthofinderReformat = rbind(orthofinderReformat, df)
  }
}

colnames(orthofinderReformat)[colnames(orthofinderReformat) == 'Orthogroup'] = 'orthofinder_cluster'

# Orthologer
orthologerReduced = orthologerFile[,c('orthologer_cluster', 'genes')]

###### COMBINE ######
masterTable = merge(busco, orthologerReduced, by = "genes", all.x = T,
                    all.y = F)
masterTable = merge(masterTable, sonicReformat, by = "genes", all.x = T,
                    all.y = F)
masterTable = merge(masterTable, orthofinderReformat, by = "genes", all.x = T,
                    all.y = F)

# Clean up 
rm(orthologerReduced, orthofinderReformat, orthofinderFile, orthologerFile,
   sonicReduced, sonicReformat, orthofinderFile, orthologerFile, sonicFile)

####### CLUSTERS PER BUSCO ID ######
clusters_per_id = NULL
ids = busco$Busco_id

for (id in ids) {
  OL_clstr = masterTable[masterTable$Busco_id == id,c('orthologer_cluster')] %>%
    unique() %>% length()
  S_clstr = masterTable[masterTable$Busco_id == id,c('sonic_cluster')] %>%
    unique() %>% length() 
  OF_clstr = masterTable[masterTable$Busco_id == id,c('orthofinder_cluster')] %>%
    unique() %>% length()
  
  newRow = c(id, OL_clstr, S_clstr, OF_clstr)
  if (is.null(clusters_per_id)) {
    clusters_per_id = newRow
  } else {
    clusters_per_id = rbind(clusters_per_id, newRow)
  }
}

colnames(clusters_per_id) = c('Busco_id', 'orthologer_cnt', 
                              'sonicparanoid_cnt', 'orthofinder_cnt')

write.table(clusters_per_id, file = "clusters_per_busco_id.tsv", quote = F,
            sep = '\t', row.names = F)

####### BUSCO IDs PER CLUSTER ######
# Orthologer 
clusters = unique(masterTable$orthologer_cluster)
clusterTable = NULL

for (cluster in clusters) {
  buscos = masterTable[masterTable$orthologer_cluster == cluster,c('Busco_id')] %>%
    unique() %>% length()
  
  newRow = c(cluster, buscos)
  
  if (is.null(clusterTable)) {
    clusterTable = newRow
  } else {
    clusterTable = rbind(clusterTable, newRow)
  }
}
colnames(clusterTable) = c("orthologer_cluster","busco_cnt")
write.table(clusterTable, file = "orthologer_ids_per_cluster.tsv", sep = '\t', 
            row.names = F, quote = F)

# Sonicparanoid 
clusters = unique(masterTable$sonic_cluster)
clusterTable = NULL

for (cluster in clusters) {
  buscos = masterTable[masterTable$sonic_cluster == cluster,c('Busco_id')] %>%
    unique() %>% length()
  
  newRow = c(cluster, buscos)
  
  if (is.null(clusterTable)) {
    clusterTable = newRow
  } else {
    clusterTable = rbind(clusterTable, newRow)
  }
}
colnames(clusterTable) = c("sonic_cluster","busco_cnt")
write.table(clusterTable, file = "sonic_ids_per_cluster.tsv", sep = '\t', 
            row.names = F, quote = F)

# Orthofinder 
clusters = unique(masterTable$orthofinder_cluster)
clusterTable = NULL

for (cluster in clusters) {
  buscos = masterTable[masterTable$orthofinder_cluster == cluster,c('Busco_id')] %>%
    unique() %>% length()
  
  newRow = c(cluster, buscos)
  
  if (is.null(clusterTable)) {
    clusterTable = newRow
  } else {
    clusterTable = rbind(clusterTable, newRow)
  }
}
colnames(clusterTable) = c("orthofinder_cluster","busco_cnt")
write.table(clusterTable, file = "orthofinder_ids_per_cluster.tsv", sep = '\t', 
            row.names = F, quote = F)