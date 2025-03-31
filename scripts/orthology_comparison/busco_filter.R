#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
# 1st argument = filteredTables

library(stringr)
library(dplyr)
table_path = args[1]
table_files = list.files(path = table_path, pattern = '\\.tsv')
mergedtable = NULL

# Get the IDs that are present in every table 
for (table_file in table_files) {
  tsvFile = read.delim(paste(table_path, table_file, sep = "/"),
                       header = F, comment.char = "#")
  colnames(tsvFile) = c('Busco_id',	'Status',	'Sequence',	'Score',	'Length',
                        'OrthoDB_url',	'Description')
  
  collapsedTable = summarise(group_by(tsvFile, Busco_id), 
                             genes = paste(Sequence, collapse =","))
  
  species = str_split_1(basename(table_file), pattern = '_')[1]
  
  colnames(collapsedTable)[colnames(collapsedTable) == "genes"] = species
  
  extractTable = collapsedTable[,c('Busco_id', species)]
  
  if (is.null(mergedtable)) {
    mergedtable = extractTable
  } else {
    mergedtable = merge(mergedtable, extractTable, by = 'Busco_id', all = T)
  }
  
  
}

commonIDs = mergedtable[complete.cases(mergedtable),]

# Write tables with only shared IDs
for (table_file in table_files) {
  tsvFile = read.delim(paste(table_path, table_file, sep = "/"),
                       header = F, comment.char = "#")
  colnames(tsvFile) = c('Busco_id',	'Status',	'Sequence',	'Score',	'Length',
                        'OrthoDB_url',	'Description')
  
  newTable = tsvFile[tsvFile$Busco_id %in% commonIDs$Busco_id,]
  
  species = str_split_1(basename(table_file), pattern = '_')[1]
  write.table(newTable, file = paste('filtered_tables/', species, '_common.tsv',
                                     sep = ""),
              col.names = F, row.names = F, quote = F, sep = '\t')
  
}