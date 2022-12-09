# clear workspace
rm(list = ls())

pacman::p_load(
  ggplot2
)

# set working directory
setwd("~/Documents/GitHub/ML4FG/plink/EUR")

# run PCA
system("~/Documents/GitHub/ML4FG/plink/plink --bfile EUR_ready --pca --out pca")

# read in the eigenvectors and eigenvalues files
eigenvals <- read.table("pca.eigenval")
eigenvecs <- read.table("pca.eigenvec")

# proportion of variation captured by each eigenvec
eigen_percent <- round((eigenvals / (sum(eigenvals)) * 100), 2)


# pca plot
ggplot(data = eigenvecs) + 
  geom_point(mapping = aes(x = V3, y=V4), size = 3, show.legend = TRUE) + 
  geom_hline(yintercept = 0, linetype = "dotted") + 
  geom_vline(xintercept = 0, linetype = "dotted") +
  labs(x = paste0("Principal component 1 (",eigen_percent[1,1]," %)"),
       y = paste0("Principal component 2 (",eigen_percent[2,1]," %)")) + 
  theme_minimal()


# scree-plot
ggplot(data = eigenvals) + 
  geom_point(aes(x=c(1:20), y=V1), size=3) + 
  geom_line(aes(x=c(1:20), y=V1)) + 
  geom_vline(xintercept = 5, linetype = "dashed") +
  labs(x = "Component",
       y = "Explained Variance") +
  theme(
    plot.title = element_text(color = "black", size = 14, face = "bold"),
    plot.subtitle = element_text(color = "black", size = 10)) +
  theme_minimal()
    