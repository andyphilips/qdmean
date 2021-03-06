# qdmean
A program to automatically quasi-demean regressors following a FGLS-RE or MLE-RE regression. Available in both R and Stata

## Stata
`qdmean` is a program to automatically quasi-demean regressors following the estimation of a random effects (either using FGLS or maximum likelihood) model. This program requires you to first estimate a model using `xtreg`, with options `, re` or `, mle`. The program will automatically obtain `theta_i` and generate quasi-demeaned regressors, which are useful for post-estimation analysis. See the Stata help file for more details.

To install `qdmean` in Stata direct from Github, type the following:
```
cap ado uninstall qdmean
net install qdmean, from(https://github.com/andyphilips/qdmean/raw/main/)
```

## R
`qdmean()` in `R` requires the estimation of a random effects model using either `plm` or `lmer`. Once estimated, pass the model, predictor variable (in quotes), and grouping variable (in quotes). If using `lmer`, additionally pass the dataset used to estimate the model and the dependent variable (in quotes). For help and examples, reference `?qdmean`

To install `qdmean` in `R` direct from Github, use the `devtools` package:
```
library(devtools)
install_github(''andyphilips/qdmean'')
library(qdmean) 
```

## Authors
Soren Jordan, Department of Political Science, Auburn University

Andrew Q. Philips, Department of Political Science, University of Colorado Boulder
   
## References
If you use `qdmean`, please cite:

Jordan, Soren and Andrew Q. Philips. 2022. "Improving the interpretation of random effects regression results." _Political Studies Review_: 1-11.
