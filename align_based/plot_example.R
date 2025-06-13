#!/usr/bin/env Rscript
library(tidyverse)

pid <- read.table("DBVPG_3857.pid",header=TRUE)
pdf("histogram_plots.pdf")
hist(pid$Identity,100)
hist(subset(pid,Identity >75)$Identity,100)
print("high")
high<- subset(pid,Identity >=95)
h<-sum(high$Identity/100 * high$Aln_Length)
sprintf("%.0f bp are in the high id category",h)

low <- subset(pid,Identity <95)
s <- sum(low$Identity/100 * low$Aln_Length)
sprintf("%.0f bp are in the low id category",s)
