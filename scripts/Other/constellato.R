#!/usr/bin/env Rscript

###### THIS SCRIPT USED TO BE PART OF: #####
# https://github.com/Kaiden-exe/comparison_analysis #
# See also: https://github.com/MetazoaPhylogenomicsLab/constellatoR

args = commandArgs(trailingOnly=TRUE)
# 1st argument = outDir
# 2nd argument = species.txt 
# 3rd argument = GOsdir
# 4th argument = DEG_OG
# 5th argument = "ortholog_groups.tsv"

library(constellatoR)
library(stringr)
library(tidyr)
library(dplyr)

OGs <- args[5]
convertedOGs = paste(args[1], "orthogroups_converted.tsv", sep="/")
rawOGs = read.delim(OGs, na.strings = "*")

species = read.table(args[2])
species = as.vector(species[,1])

GOsdir = args[3]

# Convert to orthofinder-like output
rawOGs = rawOGs[,!names(rawOGs) %in% 
              c("group_size", "sp_in_group", "seed_ortholog_cnt")]
colnames(rawOGs) = gsub(".fasta", "", colnames(rawOGs))
names(rawOGs)[names(rawOGs) == "group_id"] <- "Orthogroup"
rawOGs$Orthogroup = str_pad(rawOGs$Orthogroup, 7, side = "left", pad="0")
rawOGs$Orthogroup = paste("OG", rawOGs$Orthogroup, sep="")
write.table(rawOGs, file=convertedOGs, sep = "\t", quote = F, row.names = F)

# Prepare selection of OGs from DEG data 
DEG = read.delim(paste(args[4], "/maxlog2FC_FCs.tsv"))
names(DEG)[names(DEG) == "group_id"] <- "Orthogroup"
DEG$Orthogroup = str_pad(DEG$Orthogroup, 7, side = "left", pad="0")
DEG$Orthogroup = paste("OG", DEG$Orthogroup, sep="")

maxMedianOGs = slice_max(DEG, order_by = median, n = 50)
maxMedianOGs = maxMedianOGs$Orthogroup

DEG$delta = DEG$max - DEG$min
maxDeltaOGs = slice_max(DEG, order_by = delta, n = 50)
maxDeltaOGs = maxDeltaOGs$Orthogroup

# Create matrix
GOsfromOGs <- prepareGOsfromOGs(convertedOGs, GOsdir, species = species)

# Median
semSim <- getSemSim(GOsfromOGs = GOsfromOGs, selectedOGs = maxMedianOGs)
simMat <- getSimMat(GOsfromOGs = GOsfromOGs, selectedOGs = maxMedianOGs,
                    semSim = semSim)

# Cluster & create wordcloud 
clustersMedian <- clusterOGs(simMat)
stopwords <- system.file("extdata/bio-stopwords.txt", package="constellatoR")
wcl <- getWordcloud(GOsfromOGs, clusters = clustersMedian, toExclude = stopwords)

# Annotate 
annotation <- annotateOGs(GOsfromOGs, maxMedianOGs)
annotMedian <- merge(annotation, wcl, by.x = 0, by.y = 0)
row.names(annotMedian) <- annotMedian[, 1]
annotMedian <- annotMedian[, -1]

# Plot
groups <- sapply(row.names(annotMedian), function(x){
  paste(colnames(rawOGs)[rawOGs[which(rawOGs$Orthogroup == x), ] != ""][-1], collapse = ", ")
})

size <- sapply(row.names(annotMedian), function(x){
  sum(unlist(strsplit(as.character(rawOGs[which(rawOGs$Orthogroup == x), -1]), ", ")) != "")
})

annotMedian <- data.frame(annotMedian, groups = groups, size = size)

pMedian <- plotConstellation(clustersMedian, annotMedian, term = "BP1", color = "groups", size = "size")
ggsave(paste(args[1], "constellatoR_Median.png", sep = "/"), plot = pMedian)

# Delta
semSim <- getSemSim(GOsfromOGs = GOsfromOGs, selectedOGs = maxDeltaOGs)
simMat <- getSimMat(GOsfromOGs = GOsfromOGs, selectedOGs = maxDeltaOGs,
                    semSim = semSim)

# Cluster & create wordcloud 
clustersDelta <- clusterOGs(simMat)
stopwords <- system.file("extdata/bio-stopwords.txt", package="constellatoR")
wcl <- getWordcloud(GOsfromOGs, clusters = clustersDelta, toExclude = stopwords)

# Annotate 
annotation <- annotateOGs(GOsfromOGs, maxDeltaOGs)
annotDelta <- merge(annotation, wcl, by.x = 0, by.y = 0)
row.names(annotDelta) <- annotDelta[, 1]
annotDelta <- annotDelta[, -1]

# Plot
groups <- sapply(row.names(annotDelta), function(x){
  paste(colnames(rawOGs)[rawOGs[which(rawOGs$Orthogroup == x), ] != ""][-1], collapse = ", ")
})

size <- sapply(row.names(annotDelta), function(x){
  sum(unlist(strsplit(as.character(rawOGs[which(rawOGs$Orthogroup == x), -1]), ", ")) != "")
})

annotDelta <- data.frame(annotDelta, groups = groups, size = size)

pDelta <- plotConstellation(clustersDelta, annotDelta, term = "BP1", color = "groups", size = "size")
ggsave(paste(args[1], "constellatoR_Median.png", sep = "/"), plot = pDelta)