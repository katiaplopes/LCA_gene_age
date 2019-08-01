###Check libraries######################################
if (!"ggplot2" %in% installed.packages()) install.packages("ggplot2", repos="http://cran.rstudio.com/")
if (!"reshape2" %in% installed.packages()) install.packages("reshape2", repos="http://cran.rstudio.com/")
library(ggplot2)
library(reshape2)

###Default arguments####################################
input <- "/Users/katia/Desktop/kt/geneage_data_cumulative_KEGG_ko.txt"
output <- "/Users/katia/Desktop/kt/geneage_data_cumulative_t.pdf"
titulo <- "Brite Kegg by UEKO - KO's"
xLabel <- "Last common ancestor"
yLabel <- "KO"
legendLabel <- "Groups"
norm_zero2one <- T #Para usar em gráficos normalizados = T, ou não = F.

###Aditional Options####################################
pdf_x_res = 3840
pdf_y_res = 2160

###Read data#############################################
fid <- file(input)
table_data <- read.table(fid, sep = "\t", header = T, check.names=FALSE)
header <- colnames(table_data)
clades <- table_data$Name
table_data$Rank <- 1:length(clades)

data <- table_data[,c("Rank",header[-1:-3])]
test_data_long <- melt(data,id.vars="Rank")
if (norm_zero2one){
  test_data_long$value = test_data_long$value/max(test_data_long$value)
}

###Write to file###########################################
pdf(output, paper="a4r", width = pdf_x_res, height = pdf_y_res)

ggplot(data=test_data_long,
       aes(x=Rank, y=value, colour=variable)) +
  geom_line(aes(linetype=variable),size=1) +
  geom_point(size=2) + 
  scale_linetype_manual(values=c("dashed",rep("solid",length(header[-1:-4])))) +
  scale_x_continuous(breaks=c(1:length(clades)), labels=clades) +
  ylim(0, max(test_data_long$value)) +
  labs(list(title = titulo, x = xLabel, y = yLabel, linetype = legendLabel, colour = legendLabel)) +
  theme_bw() +
  theme(legend.key = element_blank()) +
  theme(axis.text.x = element_text(angle = 60, hjust = 1)) +
  guides(colour = guide_legend(override.aes = list(size=2)))

dev.off()
