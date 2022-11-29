# clear workspace
rm(list = ls())

# set working directory
setwd("/Users/clarkao1/Documents/ML4FG_project/plink/AFR")

# Quality control criteria
## Missingness per SNP: 0.1 --geno
## Missingness per individual: 0.1 --mind
## Minor allele frequency: 0.01 --maf
## Hardy-Weinberg threshold: 0.0000001 -hwe
######################################
# Plink Quality Control #
######################################
# make a binary file
system("/Users/clarkao1/Documents/ML4FG_project/plink/plink --bfile AFR --make-bed --out AFR")

# look at frequencies
system("/Users/clarkao1/Documents/ML4FG_project/plink/plink --bfile AFR --freq --out AFR_freq")

# check for Hardy-Weinberg disequilibrium
system("/Users/clarkao1/Documents/ML4FG_project/plink/plink --bfile AFR --hardy --out AFR_hardy")

# genotyping rate per individual and per marker
system("/Users/clarkao1/Documents/ML4FG_project/plink/plink --bfile AFR --missing --out AFR_missing")

# check for differential genotyping rate -- skipped as at least one case and one control needed
#system("/Users/clarkao1/Documents/ML4FG_project/plink/plink --bfile EUR --test-missing --out EUR_test")

# add phenotype information
system("/Users/clarkao1/Documents/ML4FG_project/plink/plink --bfile AFR --pheno pheno.txt --make-bed --out AFR_pheno")

# filter for missingness in data
system("/Users/clarkao1/Documents/ML4FG_project/plink/plink --bfile AFR_pheno --maf 0.01 --geno 0.01 --mind 0.01 --hwe 0.0000001 --hwe-all --out AFR_filtered --make-bed")

# filter for only autosomes
system("/Users/clarkao1/Documents/ML4FG_project/plink/plink --bfile AFR_filtered --chr 1-22 --out AFR_auto --make-bed")

# check for relationships between individuals with pihat > 0.2 (crytic relatedness)
system("/Users/clarkao1/Documents/ML4FG_project/plink/plink --bfile AFR_auto --genome --min 0.2 --out AFR_crytic --make-bed")

# make binary files for prepared data
system("/Users/clarkao1/Documents/ML4FG_project/plink/plink --bfile AFR_crytic --out AFR_ready --make-bed")

# make .ped and .map files for prepared data
system("/Users/clarkao1/Documents/ML4FG_project/plink/plink --bfile AFR_crytic --out AFR_ready --recode")
