# STAT293-Midterm-Project
A repository for STAT293: Methods in Applied Statistics at UC Riverside for Fall 2026. This project assesses the methodology introduced in Basu and Michailidis (2015), *Regularized Estimation in Sparse High-Dimensional Time Series Models*.

## File Descriptions

| File | Role |
|---|---|
| `README.md` | Overview of project and file roles |
| `00_requirements.R` | Installs and loads `glmnet`, `ggplot2`, `knitr`, `rmarkdown`, and `BigVAR` |
| `01_funct_GenerateData.R` | Function for generating simulated data  |
| `02_funct_MethodImplementation.R` | Functions for creating the lagged design and separating the training, validation, and testing observations; as well as for estimating the VAR/VARX coefficients and evaluating test predictions  |
| `03_funct_ModelEvaluation.R` | Functions for model performance metrics |
| `04_funct_SpectralAnalysis.R` | Functions for the fixed spectral radius experiment |
| `10_generate_data.Rmd` | Generates simulated data |
| `11_RMD_DataProcessing.Rmd` | Loads the simulated data, checks required objects and lag alignment, creates lagged regression designs, and saves them |
| `21_RMD_VAR_EstimatorComparison.Rmd` | Fits OLS, Ridge, and LASSO to weak/strong VAR(1) datasets; computes the original coefficient/prediction/selection metrics and produces VAR figures |
| `31_RMD_VARX_Exploration.Rmd` | Fits LASSO to one VARX-generated dataset with and without lagged Z; computes original metrics and creates the VARX plot |
| `41_RMD_FixedSpectralRadius.Rmd` | Runs the existing 20-replication fixed-radius experiment for gamma = 0.05, 0.25, 0.50; computes approximate spectral measures and produces plots |


## Reproducibility Instructions

First, download the zip file for this repository. After extracting your files, use `getwd()` in RStudio to check what file directory you're in. Then, use `setwd()` to set your file directory to the one referring to the clone of this repository on your device. Finally, run the following: 

```
source("00_requirements.R")
rmarkdown::render("10_RMD_GeneratingSimData.Rmd")
rmarkdown::render("11_RMD_DataProcessing.Rmd")
rmarkdown::render("21_RMD_VAR_EstimatorComparison.Rmd")
rmarkdown::render("31_RMD_VARX_Exploration.Rmd")
rmarkdown::render("41_RMD_FixedSpectralRadius.Rmd")
```

