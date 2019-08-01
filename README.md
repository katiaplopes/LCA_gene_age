## Description
#### August 01, 2019

> All code is in R and depends on packages from CRAN and/ or Bioconductor.

*******************************
Scripts to try
*******************************

Genomic phylostratigraphy is a statistical approach for reconstruction of macroevolutionary trends based on the principle of founder gene formation and punctuated emergence of protein families (Domazet-Loso et al 2007). Based on this methodology it's possible to determine the age for a given gene! The scripts presented here are from an integrative analysis that uses: (1) a human tissue RNASeq dat; (2) a database of orthologous proteins that allows finding the oldest relatives to each human protein along different species; (3) the taxonomy mapping of genes to lineage clades from the NCBI Taxonomy database (www.ncbi.nlm.nih.gov/taxonomy) and; (4) the time-scale mapping provided by TimeTree resource (www.timetree.org).

[Published paper](https://bmcgenomics.biomedcentral.com/articles/10.1186/s12864-016-3062-y): "Evolutionary hallmarks of the human proteome: chasing the age and coregulation of protein-coding genes". 

[Script to create the plot along time-scale](https://katiaplopes.github.io/LCA_gene_age/plot_geneage.R). You can see the plot [here](https://katiaplopes.github.io/LCA_gene_age/geneage_plot_cumulative.pdf)! 

[Script by clade](https://katiaplopes.github.io/LCA_gene_age/plot_genepeaks.R). The plot is [here](https://katiaplopes.github.io/LCA_gene_age/geneage_data_cumulative.pdf)! 

To create the tables with the cumulative values is necessary to map the genes in the orthologous groups. The time that I was working with this I've created some mySQL databases then, it was very simple to search for the LCA. A python script to retrieve data from OMA database and other shell scripts are in this repository as an example. 


*******************************
Created by:
 - Katia de Paiva Lopes
 - Bioinformatician, PhD
