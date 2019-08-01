# Katia Lopes
# Diego Souza
# Ricardo Vialle 

# The input of this script is a table with gene age in cumulative values. 
# The age is mapped from http://www.hedgeslab.org/ (2015)
# The age and the lables are in the input file = "geneage_data_cumulative.txt" 

###Check libraries######################################
if (!"plotrix" %in% installed.packages()) install.packages("plotrix", repos="http://cran.rstudio.com/")
if (!"vcd" %in% installed.packages()) install.packages("vcd", repos="http://cran.rstudio.com/")
if (!"RColorBrewer" %in% installed.packages()) install.packages("RColorBrewer", repos="http://cran.rstudio.com/")
library(plotrix)
library(vcd)
library(RColorBrewer)

###Default arguments####################################
input <- "/Users/katia/Desktop/kt/geneage_data_cumulative.txt"
output <- "/Users/katia/Desktop/kt/geneage_plot_cumulative.pdf"
logy <- F
plot_rank <- F
norm_zero2one <- T #Para usar em gráficos normalizados = T, ou não = F. 

###Aditional Options####################################
era_times <- c(0,65.5,251,542)
era_labels <- c("","Cenozoic","Mesozoic","Paleozoic")
pdf_x_res = 3840
pdf_y_res = 2160

###Read data#############################################
fid <- file(input)
table_data <- read.table(fid, sep = "\t", header = T)
header <- colnames(table_data)
clades <- table_data$Name
rank <- table_data$Rank
ages <- as.numeric(table_data$Time)

###Line colour############################################
numcol <- length(table_data[1,])-3
if (numcol>12 | numcol<3){
  colorlimits <- brewer.pal(12, "Paired")
  rbPal <- colorRampPalette(c(colorlimits[1],colorlimits[12]))
  colorarray <- rbPal(numcol)
}else{
  colorarray <- brewer.pal(numcol, "Paired")
}

###X-axis labels for hsa###################################
if (max(ages)==4200 & length(ages)==31){
  time.gap <- ifelse(ages > 1800,ages-2200,ages)
  time.at <- pretty(time.gap, n = 20)
  time.at <- time.at[time.at!=1900]
  time.label <- ifelse(time.at>1800, time.at+2200, time.at)
}else{
  time.gap <- ages
  time.at <- pretty(ages, n = 20)
  time.label <- time.at
}

###Write to file###########################################
pdf(output, paper="a4r", width = pdf_x_res, height = pdf_y_res)


if (logy){
  datable = log(table_data[,4:length(table_data[1,])]+1)
  maxy = apply(datable,1,max)
  yaxisval = c(0,log(seq.log(1,1000,4,F)+1))
  yaxislabel = seq.log(1,1000,5,T)
}else{
  datable = table_data[,4:length(table_data[1,])]
  maxy = apply(datable,1,max)
  yaxisval = pretty(maxy)
  yaxislabel = pretty(maxy)
}
if (norm_zero2one){
	yaxisval = pretty(0:100/100) #Label de 0 a 1 no y.
	yaxislabel = pretty(0:100/100)
}
count = 1
par(mar=c(7, 4, 5, 7)+0.1) #c(bottom, left, top, right)
plot(time.gap * (-1), datable[,count],
     type="b", # b=both (point and lines)
     col=colorarray[count], # color
     xaxt="n", # dont plot x axis
     pch= 15, # symbol code (15=squares)
     lty = "dotted", # line type (3=dotted line)
     lwd=2, # line width
     lend=1, # line style (1=butt)
     ljoin="round", # line join style
     cex = 1,
     asp=-2, # aspect ratio y/x
     ylab="Proteins count", # y axis label
     xlab=" ", # y axis label
     main="RNASeq from 14 tissues with FPKM > 10", # title
	 ylim=c(min(yaxisval),max(yaxisval)), #Parametro para inserir o zero na label do y
	 yaxs = "r",
     axes = FALSE) # show axis
for (i in 2:length(datable[1,]) ) {
  count <- count + 1
  lines(time.gap * (-1),datable[,i],
        type = "b", # b=both (point and lines)
        pch= 15, # symbol code (15=squares)
        lty = "dotted", # line type
        lwd=2, # line width
        lend=1, # line style (1=butt)
        ljoin="round", # line join style
        cex = 1,
        col=colorarray[count]) # color
}
points_color = rainbow(length(clades))
par(new = TRUE)
plot(time.gap * (-1), datable[,1],
     type="p", # points
     col=points_color, # color
     pch= 15, # symbol code (15=squares)
     ylab=" ", # y axis label
     xlab=" ", # y axis label
     cex = 0.6,
	 ylim=c(min(yaxisval),max(yaxisval)),
	 yaxs = "r",
     axes = FALSE) # show axis
for (i in 2:length(datable[1,]) ) {
  lines(time.gap * (-1),datable[,i],
        type="p", # points
        pch= 15, # symbol code (15=squares)
        col=points_color, # color
        ylab=" ", # y axis label
        xlab=" ", # y axis label
        cex = 0.6)
}
if (plot_rank){
  text(time.gap * (-1),maxy, 
       font = 2, #bold
       col = "#3B3131", #color
       labels = rank, 
       adj = 1, 
       srt = 0, 
       pos = 3, 
       xpd = TRUE, 
       cex= 0.6, 
       offset = 0.5)
}

axis(1,line=0,at=time.at*(-1), labels=time.label*(-1),  las= 2, cex.axis=0.8)
mtext("Mya",1,line=0,at=50)

axis(1,line=3, at=era_times*(-1), label=era_labels, las=1, cex.axis=0.8)
mtext("ERA",1,line=3,at=50)

axis(2, at=yaxisval, label=yaxislabel, las=2, cex.axis=0.8)

header[4:(length(table_data[1,]))] = c("OMA(11,497)","HK_Rnaseq(1,015)", "Tissue spec(3,108)") #Legenda do lado direito do gráfico

legend(50,max(datable), header[4:(length(table_data[1,]))], cex= .75, lwd = c(2.5,2.5,2.5,2.5),
       col = c(colorarray), bty='n', xpd = TRUE) 
legend(50,0.7*max(datable), clades, cex= .5,
       col = points_color, bty='n', xpd = TRUE, pch = 15)

###X-axis break for hsa###################################
if (max(ages)==4200 & length(ages)==31){
  axis.break(1,1900 *(-1),style="slash")
  abline(v=seq(-1900,-1899,1),lty=2,col="#98AFC7")
}

dev.off()
