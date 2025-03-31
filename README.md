# Run modules 
Adjust config file and then run:
bash module.sh config_module.sh

# Modules
* alt_annot: transfer annotation from model species to non-model species
* OG_DEG: get tables of highest Log2FC per species per cluster (needs SonicParanoid output)
* orthology_comparison: compares OrthoLoger, OrthoFinder and SonicParanoid output using BUSCO IDs

# Other scripts
Not dynamic, but may be used as a template 
* baseMeans.R --> separates basemeans before and after treatment and plots them against Log2FC 
* constellato.R --> Run constellator on subset of OGs (based on top 50 highest Log2FC, this uses a table created by the OG_DEG module.)
