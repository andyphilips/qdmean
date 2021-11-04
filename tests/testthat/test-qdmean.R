context("Testing the demeaning function")

library(plm)
library(lme4)

test_that("Errors are issued correctly", {
	model.plm <- plm(ln_wage ~ wks_work + union, index = c("idcode", "year"),
            data = nlswork,
            model = "random", random.method = "swar", effect = "individual")
            
	model.lmer <- lmer(ln_wage ~ wks_work + union + (1 | idcode), 
		data = nlswork)

	model.lm <- lm(ln_wage ~ wks_work + union, data = nlswork)
	
	expect_error(qdmean(predictor = "wks_work", group = "idcode"), 
				"Supply a plm or lmer model with random effects")
				
	expect_error(qdmean(model = model.plm, group = "idcode"), 
				"Indicate the predictor variable you want quasi-demeaned")
				
	expect_error(qdmean(model = model.plm, predictor = "wks_work"), 
				"Indicate the grouping variable")
				
	expect_error(qdmean(model = model.lm, predictor = "wks_work", group = "idcode"), 
				"Model must be either plm or lmer")
				
	expect_error(qdmean(model = model.lmer, predictor = "wks_work", group = "idcode", 
					data = nlswork), 
				"Dependent variable must be supplied")
				
	expect_error(qdmean(model = model.lmer, predictor = "wks_work", group = "idcode", 
					dv = "ln_wage"), 
				"dataframe of observations to estimate model must be supplied with lmer")
})    

   
test_that("Demeaning is identical to estimated (plm)", {
	model.plm <- plm(ln_wage ~ wks_work + union, index = c("idcode", "year"),
            data = nlswork,
            model = "random", random.method = "swar", effect = "individual")

	wkswork.plm.qd <- qdmean(model = model.plm, predictor = "wks_work", group = "idcode")
	lnwage.plm.qd <- qdmean(model = model.plm, predictor = "ln_wage", group = "idcode")
	union.plm.qd <- qdmean(model = model.plm, predictor = "union", group = "idcode")
	const.plm.qd <- 1 - summary(model.plm)$ercomp$theta

	test.data.plm <- data.frame(
		wks.work = wkswork.plm.qd,
		lnwage = lnwage.plm.qd,
		union = union.plm.qd,
		const = const.plm.qd
	)

	# round and reorder coef to be same
	plm.coef <- round(c(coef(model.plm)[2:3], coef(model.plm)[1]), digits = 5)
	plm.qd.coef <- round(coef(lm(lnwage ~ wks.work + union + const - 1, data = test.data.plm)), digits = 5)
	names(plm.coef) <- names(plm.qd.coef) <- c("wks_work", "union", "constant")
})

test_that("Demeaning is identical to estimated (lmer)", {
	model.lmer <- lmer(ln_wage ~ wks_work + union + (1 | idcode), data = nlswork)

	maxT.lmer <- as.numeric(ave(nlswork[["idcode"]], nlswork[["idcode"]], FUN = function(x) length(x)))
	sig_u.lmer <- as.data.frame(VarCorr(model.lmer))[as.data.frame(VarCorr(model.lmer))$grp == "idcode", "sdcor"]
	sig_e.lmer <- as.data.frame(VarCorr(model.lmer))[as.data.frame(VarCorr(model.lmer))$grp == "Residual", "sdcor"]
	theta.lmer <- 1 - sqrt(sig_e.lmer^2/(maxT.lmer*(sig_u.lmer)^2 + sig_e.lmer ^2))
	const.lmer.qd <- 1 - theta.lmer

	wkswork.lmer.qd <- qdmean(model = model.lmer, predictor = "wks_work", group = "idcode", data = nlswork, dv = "ln_wage")
	lnwage.lmer.qd <- qdmean(model = model.lmer, predictor = "ln_wage", group = "idcode", data = nlswork, dv = "ln_wage")
	union.lmer.qd <- qdmean(model = model.lmer, predictor = "union", group = "idcode", data = nlswork, dv = "ln_wage")

	test.data.lmer <- data.frame(
		wks.work = wkswork.lmer.qd,
		lnwage = lnwage.lmer.qd,
		union = union.lmer.qd,
		const = const.lmer.qd
	)

	lmer.coef <- round(c(fixef(model.lmer)[2:3], fixef(model.lmer)[1]), digits = 5)
	lmer.qd.coef <- round(coef(lm(lnwage ~ wks.work + union + const - 1, data = test.data.lmer)), digits = 5)
	names(lmer.coef) <- names(lmer.qd.coef) <- c("wks_work", "union", "constant")

	expect_identical(lmer.coef, lmer.qd.coef)
})
