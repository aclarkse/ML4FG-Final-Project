# clear workspace
rm(list = ls())

pacman::p_load(
  ggplot2,
  qqman,
  CMplot,
  RColorBrewer
)

#if (!requireNamespace("BiocManager", quietly=TRUE))
#  install.packages("BiocManager")
#BiocManager::install("gdsfmt", force=TRUE)
#BiocManager::install("SNPRelate")
#BiocManager::install("TxDb.Hsapiens.UCSC.hg19.knownGene")
#BiocManager::install("Gviz")
#BiocManager::install("TxDb.Hsapiens.UCSC.hg19.knownGene")
#install.packages("mapsnp_pkg-master/mapsnp_0.1.tar.gz", repos = NULL, type = "source")

# set working directory
setwd("/Users/clarkao1/Documents/ML4FG_project/plink/AFR")

# run association test
system("/Users/clarkao1/Documents/ML4FG_project/plink/plink --bfile AFR_ready --assoc --out assoc_results")

# logistic regression using only the first PC
system("/Users/clarkao1/Documents/ML4FG_project/plink/plink --allow-no-sex --bfile AFR_ready --covar pca.eigenvec --covar-number 1 --logistic --ci 0.95 --out logistic_results")

# remove NA values, those might give problems generating plots in later steps
system("awk '!/'NA'/' logistic_results.assoc.logistic > logistic_results.assoc_2.logistic")

# read in results
GWAS.results <- read.table("logistic_results.assoc_2.logistic", header=TRUE)

GWAS.results <- select(GWAS.results, c("SNP", "CHR", "BP", "P"))

### Create Manhattan Plot ###

# version 1
manhattan(res, col = c(brewer.pal(n = 5, name = "Set2")), annotatePval = 1e-4)

# version 2
SNPs <- list(filter(GWAS.results, P < 1e-5)$SNP)
CMplot(GWAS.results, plot.type = "m", LOG10 = TRUE, threshold = c(1e-6, 1e-5),
       threshold.lty=c(1,2), threshold.lwd=c(1,1), threshold.col=c("black","grey"),
       signal.col=c("red"," green"), signal.cex=c(1.5,1.5), signal.pch=c(19,19),
       chr.den.col = NULL, file = "jpg", memo = "", dpi=300, file.output = TRUE, verbose = FALSE,
       highlight = SNPs, highlight.text=SNPs, highlight.text.cex=1)

### Create QQ-Plot ###

# version 1
qq(res$P)

# version 2
CMplot(GWAS.results, plot.type="q", box=FALSE, file="jpg", memo="", dpi=300,
       conf.int=TRUE, conf.int.col=NULL, threshold.col="red", threshold.lty=2,
       file.output=TRUE,verbose=TRUE,width=5,height=5)

