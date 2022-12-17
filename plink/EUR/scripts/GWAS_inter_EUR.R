# clear workspace
rm(list = ls())

pacman::p_load(
  dplyr,
  ggplot2,
  qqman,
  CMplot,
  RColorBrewer
)

# set working directory
setwd("~/Documents/GitHub/ML4FG/plink/EUR")


# logistic regression adding interaction term with BMI
system("~/Documents/GitHub/ML4FG/plink/plink --allow-no-sex --bfile EUR_ready --logistic interaction --ci 0.95 --covar covars.txt --out log_int")

# remove NA values, those might give problems generating plots in later steps
system("awk '!/'NA'/' log_int.assoc.logistic  > results_int")

# read in results
GWAS.results <- read.table("results_int", header=TRUE)

# test for genomic inflation
test.genomic.inflation <- function(data, plot=FALSE, proportion=1.0,
                                   method="regression", filter=TRUE, df=1,... ) {
  data <- data[which(!is.na(data))]
  if (proportion>1.0 || proportion<=0)
    stop("proportion argument should be greater then zero and less than or equal to one")
  
  ntp <- round( proportion * length(data) )
  if ( ntp<1 ) stop("no valid measurements")
  if ( ntp==1 ) {
    warning(paste("One measurement, lambda = 1 returned"))
    return(list(estimate=1.0, se=999.99))
  }
  if ( ntp<10 ) warning(paste("number of points is too small:", ntp))
  if ( min(data)<0 ) stop("data argument has values <0")
  if ( max(data)<=1 ) {
    #       lt16 <- (data < 1.e-16)
    #       if (any(lt16)) {
    #           warning(paste("Some probabilities < 1.e-16; set to 1.e-16"))
    #           data[lt16] <- 1.e-16
    #       }
    data <- qchisq(data, 1, lower.tail=FALSE)
  }
  if (filter)
  {
    data[which(abs(data)<1e-8)] <- NA
  }
  data <- sort(data)
  ppoi <- ppoints(data)
  ppoi <- sort(qchisq(ppoi, df=df, lower.tail=FALSE))
  data <- data[1:ntp]
  ppoi <- ppoi[1:ntp]
  # s <- summary(lm(data~offset(ppoi)))$coeff
  #       bug fix thanks to Franz Quehenberger
  
  out <- list()
  if (method=="regression") {
    s <- summary( lm(data~0+ppoi) )$coeff
    out$estimate <- s[1,1]
    out$se <- s[1,2]
  } else if (method=="median") {
    out$estimate <- median(data, na.rm=TRUE)/qchisq(0.5, df)
    out$se <- NA
  } else if (method=="KS") {
    limits <- c(0.5, 100)
    out$estimate <- estLambdaKS(data, limits=limits, df=df)
    if ( abs(out$estimate-limits[1])<1e-4 || abs(out$estimate-limits[2])<1e-4 )
      warning("using method='KS' lambda too close to limits, use other method")
    out$se <- NA
  } else {
    stop("'method' should be either 'regression' or 'median'!")
  }
  
  if (plot) {
    lim <- c(0, max(data, ppoi,na.rm=TRUE))
    #       plot(ppoi,data,xlim=lim,ylim=lim,xlab="Expected",ylab="Observed", ...)
    oldmargins <- par()$mar
    par(mar=oldmargins + 0.2)
    plot(ppoi, data,
         xlab=expression("Expected " ~ chi^2),
         ylab=expression("Observed " ~ chi^2),
         ...)
    abline(a=0, b=1)
    abline(a=0, b=out$estimate, col="red")
    par(mar=oldmargins)
  }
  
  out
}

lambda <- test.genomic.inflation(GWAS.results$P)
lambda

GWAS <- select(GWAS.results, c("SNP", "CHR", "BP", "P"))

# for generating the locuszoom plot
# http://locuszoom.org/genform.php?type=yourdata
locus <- select(GWAS.results, c("SNP", "P"))
write.table(locus , file="AFR_res.txt", sep = "\t", quote=FALSE, row.names = FALSE)


### Manhattan Plot ###
SNPs <- list(filter(GWAS, P < 1e-5)$SNP)
CMplot(GWAS, plot.type = "m", LOG10 = TRUE, threshold = c(1e-5),
       threshold.lty=c(2), threshold.lwd=c(1), threshold.col=c("grey"),
       signal.col=c("red"), signal.cex=c(1.5), signal.pch=c(19),
       chr.den.col = NULL, file = "jpg", memo = "", dpi=400, file.output = TRUE, verbose = FALSE,
       highlight = SNPs, highlight.text=SNPs, highlight.text.cex=1)

### QQ Plot ###
CMplot(GWAS, plot.type="q", box=FALSE, file="jpg", memo="", dpi=400,
       conf.int=TRUE, conf.int.col=NULL, threshold.col="red", threshold.lty=2,
       file.output=TRUE,verbose=TRUE,width=5,height=5)
