# version 0.1.1
# 11/3/2021
# Authors: Soren Jordan, Andrew Q. Philips

# Corrections since previous version:
#  

# TO DO: 
#	

# Datasets exported: 
#' Data on wages and unemployment over time. From Stata: 
#' please see (and cite) \url{https://www.stata-press.com/data/r16/}
#'
#' @format A data frame with 18858 rows and 5 variables. Complete
#' observations from the original data, owned and released by Stata:
#' \describe{
#'   \item{ln_wage}{Natural log of wage}
#'   \item{idcode}{Respondent idcode}
#'   \item{year}{Year}
#'   \item{wks_work}{Amount worked}
#'   \item{union}{Union member (dummy)}
#' }
#' @source \url{https://www.stata-press.com/data/r16/}
#' @docType data
#' @keywords datasets
#' @usage data(nlswork)
#' @name nlswork
NULL


## Functions:
## Dependencies: 	plm
#					lme4
#
## Functions included:
# (1) qdmean
#	model = model from which to qdemean
#	predictor = predictor to qdemean
#	group = grouping variable to qdemean
#	data = if a lmer model, dataset is required
#	dv = if a lmer model, dv is required


###########################################
# ------------(1) qdmean ----------------#
###########################################
#' Quasi-demean a variable, based on estimate of theta
#' @param model an estimated random effects model
#' @param predictor the predictor variable to quasi-demean
#' @param group the grouping variable to use to quasi-demean
#' @param data if a lmer model, the dataset used to estimate the model
#' @param dv if a lmer model, the dependent variable (as a string in quotes)
#' @return the quasi-demeaned independent variable
#' @details
#' if using a \code{lmer} model, pass the data with no \code{NA} observations
#' @importFrom lme4 VarCorr
#' @importFrom lme4 lmer
#' @importFrom plm plm fixef index
#' @importFrom stats na.omit ave
#' @author Soren Jordan and Andrew Q. Philips
#' @keywords demean
#' @examples
#' \dontrun{
#' # using plm
#' model.plm <- plm(ln_wage ~ wks_work + union, index = c("idcode", "year"),
#'          data = nlswork,
#'          model = "random", random.method = "swar", effect = "individual")
#' # quasi-demean wks_work
#' wkswork.plm <- qdmean(model = model.plm, predictor = "wks_work", group = "idcode")
#' summary(wkswork.plm)
#' 
#' # using lmer
#' model.lmer <- lmer(ln_wage ~ wks_work + union + (1 | idcode),
#'          data = data)
#' # quasi-demean wks_work
#' wkswork.lmer <- qdmean(model = model.lmer, predictor = "wks_work", group = "idcode", 
#'          data = nlswork, dv = "ln_wage")
#' summary(wkswork.lmer)
#' }
#' @export


qdmean <- function(model, predictor, group, data, dv) {
	if(missing(model)) {
		stop("Supply a plm or lmer model with random effects")
	}
	if (!(class(model)[1] %in% c("plm", "lmerMod"))) { # if it's not plm/lmer
		stop("Model must be either plm or lmer")
	}
	if(missing(predictor)) {
		stop("Indicate the predictor variable you want quasi-demeaned (as a string)")
	}
	if(missing(group)) {
		stop("Indicate the grouping variable (as a string)")
	}
	if(class(predictor) != "character") {
		stop("Predictor variable must be supplied as a string")
	} 
	if(class(group) != "character") {
		stop("Grouping variable must be supplied as a string")
	} 	
	if(class(model)[1] == "plm") { # if a plm model
		# generate data from the model
		data <- data.frame(model$model, index(model), ercomp(model.plm)$theta)
		names(data) <- c(names(model$model), names(index(model)), "theta")
		# average over the predictor, given the grouping variable (both user supplied)
		data$xmean <- as.numeric(ave(data[[predictor]], data[[group]],
			FUN = function(x) mean(x, na.rm = T)))
		x.full <- as.numeric(data[[predictor]])
		# generate x.qdmean to return
		x.qdmean <- x.full - data$theta*data$xmean
	} else if(class(model)[1] == "lmerMod") { # if it's a lmer model
		if(missing(data)) {
			stop("dataframe of observations to estimate model must be supplied with lmer")
		}
		if(missing(dv)) {
			stop("Dependent variable must be supplied (as a string) with lmer")
		}
		if(class(dv) != "character") {
			stop("Dependent variable must be supplied (as a string) with lmer")
		} 
		data.lmer <- data.frame(get(group, data), get(dv, data))
		for(i in 2:length(names(fixef(model)))) {
			data.lmer <- data.frame(data.lmer, get(names(fixef(model))[i], data))
		}
		names(data.lmer) <- c(group, dv, names(fixef(model))[2:length(names(fixef(model)))])
		data.lmer <- na.omit(data.lmer)
		data.lmer$xmean <- as.numeric(ave(data.lmer[[predictor]], data.lmer[[group]],
							FUN = function(x) mean(x, na.rm = T)))
		x.full <- as.numeric(data.lmer[[predictor]])
		maxT <- as.numeric(ave(data.lmer[[group]], data.lmer[[group]], FUN = function(x) length(x)))
		sig_u <- as.data.frame(VarCorr(model))[as.data.frame(VarCorr(model))$grp == group, "sdcor"]
		sig_e <- as.data.frame(VarCorr(model))[as.data.frame(VarCorr(model))$grp == "Residual", "sdcor"]
		theta <- 1 - sqrt(sig_e^2/(maxT*(sig_u)^2 + sig_e ^2))
		x.qdmean <- x.full - theta*data.lmer$xmean
	} 
	# return qdemeaned x
	x.qdmean
}
