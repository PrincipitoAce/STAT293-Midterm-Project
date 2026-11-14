# All packages used for analysis
packages <- c("glmnet", "ggplot2", "knitr", "rmarkdown", "BigVAR")
missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]

if (length(missing) > 0) {
  install.packages(missing, repos = "https://cloud.r-project.org")
}

library(glmnet)
library(ggplot2)
library(knitr)
library(rmarkdown)