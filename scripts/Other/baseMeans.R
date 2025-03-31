# Separate begin and end basemeans 
# Plot basemean against Log2FC 

library(DESeq2)
library(ggplot2)
library(dplyr)
library(scales)

# Import tables
allSpecies = c('Asco', 'Dsat', 'Etes', 'Robe', 'Rvar')
canon_genes <- read.delim("~/Documents/data/canon_genes.tsv")
rox_genes <- read.delim("~/Documents/data/rox_genes.tsv")
tardi_genes <- read.delim("~/Documents/data/tardi_genes.tsv")
genes = rbind(canon_genes, rox_genes, tardi_genes)

for (species in allSpecies) {
  ### Get data 
  load(paste("~/Documents/data/DEG_output/", species, "_results.RData", sep=""))
  rm(pcanalysis)
  
  ### Separate BMs
  baseMeanPerLvl <- sapply(levels(dds$condition), 
                           function(lvl) rowMeans(
                             counts(dds,normalized=TRUE)[,dds$condition == lvl]))
  baseMeanPerLvl = as.data.frame(baseMeanPerLvl)
  baseMeanPerLvl$geneID = rownames(baseMeanPerLvl)
  rownames(baseMeanPerLvl) = NULL
  
  ### Add BM & log2FC
  res$geneID = res$geneID = rownames(res)
  res<-as.data.frame(res[,c(7,1:2)])
  rownames(res) = NULL
  df = merge(baseMeanPerLvl, res)
  colnames(df) = c('geneID', 'ctrl', 'IR', 'baseMean', 'log2FoldChange')
  write.table(df, file = paste("~/Pictures/Plots/basemeans/", species, 
                               '_sepBM.tsv', sep=""), 
              quote = F, sep = '\t', row.names = F)
  
  ### Identify genes of interest
  df = df %>% mutate(interest = ifelse(geneID %in% genes$geneID, 'YES', 'NO'))
  df = df %>% mutate(source = case_when(
    geneID %in% canon_genes$geneID ~ 'DNA repair',
    geneID %in% tardi_genes$geneID ~ 'Tardigrade',
    geneID %in% rox_genes$geneID ~ 'ROS scavenging',
    TRUE ~ 'Other'
  ))
  df$source = factor(df$source)
  
  ### Plotting 
  ## Control vs log2fc
  # Gen
  p = ggplot(df, aes(x = log2FoldChange, y = ctrl, color = interest)) + 
    geom_point(data = df[df$interest == 'NO',]) +
    geom_point(data = df[df$interest == 'YES',]) +
    scale_color_manual(values=c('grey', 'darkorchid4')) + 
    scale_y_log10() + theme(legend.position = 'none') + 
    labs(x = "Log2FC", y = 'Control base mean')
  ggsave(paste("~/Pictures/Plots/basemeans/", species, '_ctrl.png', sep=""),
         width = 1200, height = 1200, units = "px", plot = p)
  # separated
  p = ggplot(df, aes(x = log2FoldChange, y = ctrl, color = source)) + 
    geom_point(data = df[df$interest == 'NO',]) +
    geom_point(data = df[df$interest == 'YES',]) +
    scale_color_manual(breaks = c('DNA repair', 'Tardigrade', 'ROS scavenging',
                                  'Other'),
                         values=c('darkorchid4', 'orange1', 'mediumblue','grey')) + 
    scale_y_log10() + 
    labs(x = "Log2FC", y = 'Control base mean')
  ggsave(paste("~/Pictures/Plots/basemeans/", species, '_ctrl_sep.png', sep=""),
         width = 1500, height = 1200, units = "px", plot = p)
  
  ## IR vs log2fc
  # Gen
  p = ggplot(df, aes(x = log2FoldChange, y = IR, color = interest)) + 
    geom_point(data = df[df$interest == 'NO',]) +
    geom_point(data = df[df$interest == 'YES',]) +
    scale_color_manual(values=c('grey', 'darkorchid4')) + 
    scale_y_log10() + theme(legend.position = 'none') + 
    labs(x = "Log2FC", y = 'Irradiated base mean')
  ggsave(paste("~/Pictures/Plots/basemeans/", species, '_IR.png', sep=""),
         width = 1200, height = 1200, units = "px", plot = p)
  # separated
  p = ggplot(df, aes(x = log2FoldChange, y = IR, color = source)) + 
    geom_point(data = df[df$interest == 'NO',]) +
    geom_point(data = df[df$interest == 'YES',]) +
    scale_color_manual(breaks = c('DNA repair', 'Tardigrade', 'ROS scavenging',
                                  'Other'),
                       values=c('darkorchid4', 'orange1', 'mediumblue','grey')) + 
    scale_y_log10() + 
    labs(x = "Log2FC", y = 'Irradiated base mean')
  ggsave(paste("~/Pictures/Plots/basemeans/", species, '_IR_sep.png', sep=""),
         width = 1500, height = 1200, units = "px", plot = p)
}