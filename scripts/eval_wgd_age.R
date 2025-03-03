#!/usr/bin/env Rscript

library(tidyverse)
library(ggplot2)
library(cowplot)
library(stringr)
library(fs)
require(RColorBrewer)


folder <- "wgd"
ksfiles <- fs::dir_ls(folder,recurse=TRUE,glob="*.fa.tsv.ks.tsv")

ksdata <- ksfiles %>% map_dfr(read_tsv,.id = "source") %>%
  mutate(Name = str_split_i(source,'/',2),
         Strain = str_replace(Name,"Rhodotorula_mucilaginosa_","")) %>%
  select(-c(source)) 

ksdata_clean <- ksdata %>% filter(dS != "NaN" & alignmentcoverage > 0.8 & dS <= 1.5)
hist(ksdata_clean$dS,100)

p <- ggplot(ksdata_clean,aes(x=dS)) + geom_histogram(color="black", fill="lightblue",binwidth=0.01) + theme_cowplot(12)
p

p <- ggplot(ksdata_clean,aes(x=dS,fill=Strain)) + geom_density(alpha=0.5) + theme_cowplot(12)
p + facet_wrap(~Strain)

ksdata_clean1 <- ksdata_clean %>% filter(Strain != "F8_5S_5P" & Strain != "DBVPG_4380" & dS <0.75)
darkcolors = brewer.pal(n = 10, name="Spectral")
colors = colorRampPalette(darkcolors)(length(unique(ksdata_clean1$Strain)))


p2 <- ggplot(ksdata_clean1,aes(x=dS,fill=Strain)) + 
  geom_density(alpha=0.75) + 
  theme_cowplot(12) + 
  scale_color_manual(values=colors) + 
  scale_fill_manual(values=colors)  + ggtitle("dS distribution for Duplicate/Hybrid Strains")
p2 + facet_wrap(~Strain) 
p2 + geom_density(alpha=0.25) 
ggsave("plots/wgd_dupstrains_dS_one.pdf",p2 + geom_density(alpha=0.25) ,width=10,height=10) 

ggsave("plots/wgd_dupstrains_dS_facet.pdf",p2+facet_wrap(~Strain),width=10,height=10) 

folder <- "undup_wgd"
ksfiles <- fs::dir_ls(folder,recurse=TRUE,glob="*.fa.tsv.ks.tsv")

ksdata2 <- ksfiles %>% map_dfr(read_tsv,.id = "source") %>%
  mutate(Name = str_split_i(source,'/',2),
         Strain = str_replace(Name,"Rhodotorula_mucilaginosa_","")) %>%
  select(-c(source)) 

ksdata2_clean <- ksdata2 %>% filter(dS != "NaN" & alignmentcoverage > 0.3 & dS <= 10)
hist(ksdata2_clean$dS,100)
length(ksdata2_clean$dS)
ksdata_clean %>% group_by(Strain) %>% summarize(n=n())
