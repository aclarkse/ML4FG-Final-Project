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
pheno <-select(pheno, c("Row.names", "V2", "SPONTANEOUS"))
pheno$familyid <- as.factor(pheno$V2)
pheno$subjectid <- as.factor(pheno$V2)
pheno$value <- as.factor(pheno$SPONTANEOUS)

pheno <- select(pheno, c("Row.names", "familyid", "subjectid", "value"))
pheno %>%
  count(value)

# drop missing values
pheno <- pheno %>% drop_na(value)

# # 1 --> control, 2--> case
# get rid of values encoded as 3
pheno <- filter(pheno, value != 3)

# sanity check
pheno %>%
  count(value)

# stitch together outcome with BMI as covariates
demo <- select(demo, c("StudyID", "BMI"))
demo <- rename(demo, row = StudyID)
pheno <- rename(pheno, row = Row.names)
covars <- merge(demo, pheno, by="row")
covars <- select(covars, c("familyid", "subjectid", "value", "BMI"))

# remove observations with missing BMI
covars <- covars %>% drop_na(BMI)

create.BMI.cats <- function(df){
  df <- df %>%
    mutate(
      BMI = case_when(
        BMI < 18.5 ~ 1,                    # underweight
        18.5 <= BMI & BMI <= 24.9 ~ 2,   # normal weight
        25 <= BMI & BMI <= 29.9 ~ 3,        # overweight
        BMI >= 30 ~ 4                            # obese
    )
  )
  
  df$BMI <- as.factor(df$BMI)
  
  # remove observations with missing BMI category
  df <- df %>% drop_na(BMI)
  
  return(df)
}

#covars <- create.BMI.cats(covars)


# extract phenotype-relevant information
pheno <- select(covars, c("familyid", "subjectid", "value"))


# save files
write.table(pheno, file = "pheno.txt", sep = " ", col.names = FALSE, 
            row.names = FALSE, quote=FALSE)

covars <- select(covars, c("familyid", "subjectid", "BMI"))

write.table(covars, file = "covars.txt", sep = " ", col.names = FALSE, 
            row.names = FALSE, quote=FALSE)

