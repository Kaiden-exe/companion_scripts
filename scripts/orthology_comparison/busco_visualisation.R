library(ggplot2)
clusters_per_busco_id = read.delim("clusters_per_busco_id.tsv")

###### Orthologer ######
counts = summary(as.factor(clusters_per_busco_id$orthologer_cnt))
values = unique(clusters_per_busco_id$orthologer_cnt)
pcts = counts/sum(counts)*100
legend_labels = paste(values, " (" ,round(pcts, 2), "%)", sep="")
p = ggplot(clusters_per_busco_id, mapping = aes(x=factor(1), 
                                                fill=factor(orthologer_cnt))) +
  geom_bar(width = 1, mapping = aes(y = (..count..)/sum(..count..)),
           position = position_fill(reverse = T)) + 
  coord_polar(theta = "y") + ylab("") + xlab("") + 
  ggtitle("Orthologer clusters per BUSCO ID") +
  theme(axis.text.y=element_blank(), axis.ticks=element_blank(),
    axis.text.x=element_blank(), axis.ticks.x=element_blank()) +
  guides(fill=guide_legend(title="Clusters per ID")) +
  scale_fill_manual(labels = legend_labels, values = c("darkblue",
                                                        "mediumvioletred",
                                                        "purple4",
                                                        "darkgoldenrod3",
                                                        "mediumaquamarine"
                                                        ))

ggsave("orthologer_pie.png", plot = p)

###### Sonicparanoid ######
counts = summary(as.factor(clusters_per_busco_id$sonicparanoid_cnt))
values = unique(clusters_per_busco_id$sonicparanoid_cnt)
pcts = counts/sum(counts)*100
legend_labels = paste(values, " (" ,round(pcts, 2), "%)", sep="")
p = ggplot(clusters_per_busco_id, mapping = aes(x=factor(1), 
                                                fill=factor(sonicparanoid_cnt))) +
  geom_bar(width = 1, mapping = aes(y = (..count..)/sum(..count..)),
           position = position_fill(reverse = T)) + 
  coord_polar(theta = "y") + ylab("") + xlab("") + 
  ggtitle("Sonicparanoid clusters per BUSCO ID") +
  theme(axis.text.y=element_blank(), axis.ticks=element_blank(),
        axis.text.x=element_blank(), axis.ticks.x=element_blank()) +
  guides(fill=guide_legend(title="Clusters per ID")) +
  scale_fill_manual(labels = legend_labels, values = c("darkblue",
                                                       "mediumvioletred",
                                                       "purple4",
                                                       "darkgoldenrod3",
                                                       "mediumaquamarine"))

ggsave("sonicparanoid_pie.png", plot = p)

###### orthofinder ######
counts = summary(as.factor(clusters_per_busco_id$orthofinder_cnt))
values = unique(clusters_per_busco_id$orthofinder_cnt)
pcts = counts/sum(counts)*100
legend_labels = paste(values, " (" ,round(pcts, 2), "%)", sep="")
p = ggplot(clusters_per_busco_id, mapping = aes(x=factor(1), 
                                                fill=factor(orthofinder_cnt))) +
  geom_bar(width = 1, mapping = aes(y = (..count..)/sum(..count..)),
           position = position_fill(reverse = T)) + 
  coord_polar(theta = "y") + ylab("") + xlab("") + 
  ggtitle("Orthofinder clusters per BUSCO ID") +
  theme(axis.text.y=element_blank(), axis.ticks=element_blank(),
        axis.text.x=element_blank(), axis.ticks.x=element_blank()) +
  guides(fill=guide_legend(title="Clusters per ID")) +
  scale_fill_manual(labels = legend_labels, values = c("darkblue",
                                                       "mediumvioletred",
                                                       "purple4",
                                                       "darkgoldenrod3",
                                                       "mediumaquamarine",
                                                       "red3"))

ggsave("orthofinder_pie.png", plot = p)

###### IDs per cluster ######
# master_table = read.delim("master_table.tsv")
# # Orthologer 
# sonic_table = na.omit(master_table[,c("Busco_id", "sonic_cluster")])
# clusters = unique(sonic_table$sonic_cluster)
# clusterTable = NULL

# for (cluster in clusters) {
#   buscos = sonic_table[sonic_table$sonic_cluster == cluster,c('Busco_id')] %>%
#     unique() %>% length()
  
#   newRow = c(cluster, buscos)
  
#   if (is.null(clusterTable)) {
#     clusterTable = newRow
#   } else {
#     clusterTable = rbind(clusterTable, newRow)
#   }
# }
