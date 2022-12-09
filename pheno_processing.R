rm(list = ls())

pacman::p_load(
  dplyr,
  tidyverse
)

# set working directory
setwd("~/Documents/GitHub/ML4FG")

pheno <- read.table("pregnancy_outcomes.csv", 
                    header = TRUE, stringsAsFactors = FALSE, sep = ",")

# read in demographic information
demo <- read.table("demographics.csv", 
                   header = TRUE, stringsAsFactors = FALSE, sep = ",")

# the V2 column contains the family and individual id
pheno <-select(pheno, c("Row.names", "V2", "pOUTCOME"))
pheno$familyid <- as.factor(pheno$V2)
pheno$subjectid <- as.factor(pheno$V2)
pheno$value <- as.factor(pheno$pOUTCOME)

pheno <- select(pheno, c("Row.names", "familyid", "subjectid", "value"))
pheno %>%
  count(value)

# recode target into binary
# 1 --> control, 2--> case
pheno <- pheno %>% mutate(outcome = recode(value,
                 '3' = '2',
                 '4' = '2',
                 '5' = '2'))
pheno <- pheno %>% drop_na(outcome)

# sanity check
pheno %>%
  count(outcome)

# stitch together outcome with BMI as covariates
demo <- select(demo, c("StudyID", "BMI"))
demo <- rename(demo, row = StudyID)
pheno <- rename(pheno, row = Row.names)
covars <- merge(demo, pheno, by="row")
covars <- select(covars, c("familyid", "subjectid", "outcome", "BMI"))

# remove observations with missing BMI
covars <- covars %>% drop_na(BMI)

create.BMI.cats <- function(df){
  df <- df %>%
    mutate(
      BMI = case_when(
        BMI < 18.5 ~ 1,                # underweight
        18.5 <= BMI & BMI <= 24.9 ~ 2, # normal weight
        25 <= BMI & BMI <= 29.9 ~ 3,   # overweight
        BMI >= 30 ~ 4                  # obese
    )
  )
  
  df$BMI <- as.factor(df$BMI)
  
  # remove observations with missing BMI category
  df <- df %>% drop_na(BMI)
  
  return(df)
}

# sanity check of BMI categories
#covars %>%
#  count(BMI)

# extract phenotype-relevant information
pheno <- select(covars, c("familyid", "subjectid", "outcome"))


# save files
write.table(pheno, file = "pheno.txt", sep = " ", col.names = FALSE, 
            row.names = FALSE, quote=FALSE)

covars <- select(covars, c("familyid", "subjectid", "BMI"))

write.table(covars, file = "covars.txt", sep = " ", col.names = FALSE, 
            row.names = FALSE, quote=FALSE)
