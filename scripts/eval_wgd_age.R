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

folder <- "undup_cmp"
ksfiles <- fs::dir_ls(folder,recurse=TRUE,glob="*/Orthogroups.sp.tsv.ks.tsv")

ksdata2 <- ksfiles %>% map_dfr(read_tsv,.id = "source") %>% mutate(Name = str_split_i(source,'/',2),
         Strain = paste0(str_replace(Name,"Rhodotorula_mucilaginosa_",""), "-Inter")) %>%
  select(-c(source)) 

ksdata2_clean <- ksdata2 %>% filter(dS != "NaN" & alignmentcoverage > 0.3 & dS <= 1)

ksdata2_clean <- ksdata2_clean %>% filter(Strain != "F8_5S_5P-Inter" & Strain != "DBVPG_4380-Inter")
hist(ksdata2_clean$dS,100)
length(ksdata2_clean$dS)

ksdata_clean1 %>% group_by(Strain) %>% summarize(n=n(),
                                                 meanKS = mean(dS))
ksdata2_clean %>% group_by(Strain) %>% summarize(n=n(),
                                                 meanKS = mean(dS))

mean(ksdata_clean1$dS)
mean(subset(ksdata2_clean$dS,ksdata2_clean$dS > 0.1))
darkcolors = brewer.pal(n = 10, name="Spectral")
colors = colorRampPalette(darkcolors)(length(unique(ksdata2_clean$Strain)))

p3 <- ggplot(ksdata2_clean,aes(x=dS,fill=Strain)) + 
  geom_density(alpha=0.75) + 
  theme_cowplot(12) + 
  scale_color_manual(values=colors) + 
  scale_fill_manual(values=colors)  + ggtitle("Interstrain dS distribution for Duplicate/Hybrid Strains")
p3 + facet_wrap(~Strain) 
p3 + geom_density(alpha=0.25)

ggsave("plots/wgd_dupstrains_dS_inter.pdf",p3 + geom_density(alpha=0.25) ,width=10,height=10) 
ggsave("plots/wgd_dupstrains_dS_inter_facet.pdf",p3+facet_wrap(~Strain),width=10,height=10) 


interintra <-bind_rows(ksdata2_clean,ksdata_clean1)

darkcolors = brewer.pal(n = 8, name="Set1")
colors = colorRampPalette(darkcolors)(length(unique(interintra$Strain)))

p4 <- ggplot(interintra,aes(x=dS,fill=Strain)) + 
  geom_density(alpha=0.75) + 
  theme_cowplot(12) + 
  scale_color_manual(values=colors) + 
  scale_fill_manual(values=colors)  + ggtitle("Intra/Inter dS distribution for Duplicate/Hybrid Strains")

p4 + facet_wrap(~Strain) 
p4 + geom_density(alpha=0.25)
ggsave("plots/wgd_dupstrains_dS_inter_intra.pdf",p4 + geom_density(alpha=0.25) ,width=10,height=10) 

ggsave("plots/wgd_dupstrains_dS_inter_intra_facet.pdf",p4+facet_wrap(~Strain),width=10,height=10) 

