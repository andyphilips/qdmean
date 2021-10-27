*
*		PROGRAM QDMEAN
*		version 1.0.1
*		last updated: 10/27/21
*		authors: Soren Jordan and Andrew Q Philips
*
* ----------------------------------------------------------------------
capture program drop qdmean
capture program define qdmean, rclass
syntax , [GENerate(string)]

version 8
marksample touse // only quasi-demean on xtreg sample

* was xtreg, re/mle run (implicitly, are data xtset)?
if "`e(cmd)'" != "xtreg" {
	di in r _n "Last command was not xtreg. Run xtreg before proceeding."
	exit 198
}
if "`e(model)'" != "re"  { 
	if "`e(model)'" != "ml" {
		di in r _n "Only re or mle xtreg models can be quasi-demeaned."
		exit 198
	}
}

* -- extract colnames from e(b) --
loc xnames : colnames(e(b))
di "`xnames'"

* gen max(T) foreach i --
tempvar maxT
by `e(ivar)' : gen `maxT' = _n if `touse'
bysort `e(ivar)' : replace `maxT' = `maxT'[_N] if `touse'

* -- gen theta_i --
tempvar theta_i
gen `theta_i' = 1 - sqrt(`e(sigma_e)'^2/(`maxT'*(`e(sigma_u)')^2 + `e(sigma_e)'^2)) if `touse'

* -- gen x-bar and quasi-demean --
if "`generate'" != "" { // user-supplied name?
	loc qdm = "`generate'"
}
else {
	loc qdm = "qdm"
}

foreach i of local xnames {
	if "`i'" == "_cons" {	 // ignore constants
	}
	else {
		tempvar `i'_bar
		bysort `e(ivar)' : egen ``i'_bar' = mean(`i') if `touse' // x-bar
		gen `i'_`qdm' = `i' - `theta_i'*``i'_bar' if `touse'
	}
}

end // fin