# clear workspace
rm(list = ls())

# set working directory
setwd("~/Documents/GitHub/ML4FG/plink/EUR")

# Quality control criteria
## Missingness per SNP: 0.1 --geno
## Missingness per individual: 0.1 --mind
## Minor allele frequency: 0.01 --maf
## Hardy-Weinberg threshold: 0.0000001 -hwe
######################################
# Plink Quality Control #
######################################
# make a binary file
system("~/Documents/GitHub/ML4FG/plink/plink --bfile EUR --make-bed --out EUR")

# look at frequencies
system("~/Documents/GitHub/ML4FG/plink/plink --bfile EUR --freq --out EUR_freq")

# check for Hardy-Weinberg disequilibrium
system("~/Documents/GitHub/ML4FG/plink/plink --bfile EUR --hardy --out EUR_hardy")

# genotyping rate per individual and per marker
system("~/Documents/GitHub/ML4FG/plink/plink --bfile EUR --missing --out EUR_missing")

# check for differential genotyping rate -- skipped as at least one case and one control needed
#system("/Users/clarkao1/Documents/ML4FG_project/plink/plink --bfile EUR --test-missing --out EUR_test")

# add phenotype information
system("~/Documents/GitHub/ML4FG/plink/plink --bfile EUR --pheno pheno.txt --make-bed --out EUR_pheno")

# filter for missingness in data
system("~/Documents/GitHub/ML4FG/plink/plink --bfile EUR_pheno --maf 0.01 --geno 0.01 --mind 0.01 --hwe 0.0000001 --hwe-all --out EUR_filtered --make-bed")

# filter for only autosomes
system("~/Documents/GitHub/ML4FG/plink/plink --bfile EUR_filtered --chr 1-22 --out EUR_auto --make-bed")

# check for relationships between individuals with pihat > 0.2 (crytic relatedness)
system("~/Documents/GitHub/ML4FG/plink/plink --bfile EUR_auto --genome --min 0.2 --out EUR_crytic --make-bed")

# make binary files for prepared data
system("~/Documents/GitHub/ML4FG/plink/plink --bfile EUR_crytic --out EUR_ready --make-bed")

# make .ped and .map files for prepared data
#system("~/Documents/GitHub/ML4FG/plink/plink --bfile EUR_crytic --out EUR_ready --recode")