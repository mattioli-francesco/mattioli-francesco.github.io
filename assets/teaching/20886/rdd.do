*** Modified replication file for *******************************
*** Brollo, Nannicini, Perotti, Tabellini (2013) ****************
*** The Political Resource Curse. American Economic Review ******
*** https://www.aeaweb.org/articles?id=10.1257/aer.103.5.1759 ***

clear all											// clear STATA memory and get ready to start a new project

cd "/Users/francescomattioli/Library/CloudStorage/OneDrive-UniversitàCommercialeLuigiBocconi/PhD/TA/20886 – Foundations of Social Sciences/"					// set working directory to a familiar location

use "BNPT_AER2013_mod.dta", clear					// load the dataset



*****************************************************************
*** Sharp Regression Discontinuity Design ***********************
*****************************************************************

// assign the relevant FPM threshold based on population's closeness to FPM thresholds' midpoint (needed only when working with multiple cutoffs)
gen pop_threshold = .
replace pop_threshold = 10189 if inrange(pop, 0, 10189 + (13585 - 10189) / 2)
replace pop_threshold = 13585 if inrange(pop, 10189 + (13585 - 10189) / 2, 13585 + (16981 - 13585) / 2)
replace pop_threshold = 16981 if inrange(pop, 13585 + (16981 - 13585) / 2, 16981 + (23772 - 16981) / 2)
replace pop_threshold = 23773 if inrange(pop, 16981 + (23772 - 16981) / 2, 23773 + (30565 - 23773) / 2)
replace pop_threshold = 30565 if inrange(pop, 23773 + (30565 - 23773) / 2, 30565 + (37356 - 30565) / 2)
replace pop_threshold = 37357 if inrange(pop, 30565 + (37356 - 30565) / 2, 37356 + (44148 - 37356) / 2)
replace pop_threshold = 44149 if inrange(pop, 37356 + (44148 - 37356) / 2, 50940)

gen pop_norm = pop - pop_threshold					// normalized population (running variable)
// a running variable that equals 0 at the cutoff allows direct interpretation and reporting of regression output

gen fpm_binary = (pop_norm > 0) if pop_norm != .		// binary treatment variable (1 if running variable above the cutoff, 0 otherwise)
// necessary condition in a sharp RDD

twoway (scatter fpm_binary pop_norm if fpm_binary==0, msize(tiny) jitter(3)) (scatter fpm_binary pop_norm if fpm_binary==1, msize(tiny) jitter(3)), xlabel(, nogrid) xline(0, lpattern(solid) lwidth(medthick)) legend(order(1 "Control" 2 "Treatment") position(3) ring(0) region(fcolor(none))) xtitle("Normalized population (RV)") ytitle("P(FPM recipient = 1)") plotregion(lcolor(black))			// treatment assignment plot

cap ssc install rddensity

rddensity pop_norm, c(0) p(2)						// manipulation test
// to perform the original manupulation test as described in McCrary (2008) refer to https://eml.berkeley.edu/~jmccrary/DCdensity/

rddensity pop_norm, c(0) p(2) plot plot_n(50 50) hist_n(70 70) graph_opt(legend(off) xlabel() xtitle("Normalized population (RV)"))						// manipulation test plot

reg corruption_n fpm_binary pop_norm								// parametric linear regression

reg corruption_n fpm_binary c.pop_norm##c.pop_norm					// parametric quadratic regression

reg corruption_n fpm_binary c.pop_norm##c.pop_norm##c.pop_norm		// parametric cubicregression

reg corruption_n i.fpm_binary##c.pop_norm							// linear regression, allowing for different slopes on both sides of the cutoff

reg corruption_n i.fpm_binary##c.pop_norm if abs(pop_norm) < 822.874	// (non-parametric) local linear regression with optimal bandwidth (manual implementation)

cap ssc install rdrobust												// state-of-the-art RDD companion commands by Calonico, Cattaneo, Titiunik (CCT) – refer to https://rdpackages.github.io/rdrobust/

rdbwselect corruption_n pop_norm, c(0) p(1) kernel(uniform)				// computation of optimal bandwidth through procedure by CCT

rdrobust corruption_n pop_norm, c(0) p(1) kernel(uniform)				// local linear regression (automatic implementation)

// rdplot corruption_n pop_norm, c(0) p(1) kernel(uniform)				// companion command by CCT to plot rdrobust estimation results

cap ssc install cmogram								// command to manually create RD plots (allows more customization)

cmogram corruption_n pop_norm, cutpoint(0) lineat(0) scatter lfitci lfitopts(stdp level(95) n(100) ciplot(rline) clpattern(dash) clwidth(medium) clcolor(black) alcolor(black) alpattern(shortdash) alwidth(medium)) histopts(bin(30)) graphopts(legend(off) xtitle("Normalized population (RV)") xline(0, lpattern(solid) lwidth(medthick)) ytitle("P(# corruption episodes > 0)") plotregion(lcolor(black)))		// manual RD plot (linear fit – parametric approach)

cmogram corruption_n pop_norm if abs(pop_norm) < 822.874, cutpoint(0) lineat(0) scatter lfitci lfitopts(stdp level(95) n(100) ciplot(rline) clpattern(dash) clwidth(medium) clcolor(black) alcolor(black) alpattern(shortdash) alwidth(medium)) histopts(bin(30)) graphopts(legend(off) xtitle("Normalized population (RV)") xline(0, lpattern(solid) lwidth(medthick)) ytitle("P(# corruption episodes > 0)") plotregion(lcolor(black)))		// manual RD plot (linear fit – local linear regression)

cmogram corruption_n pop_norm, cutpoint(0) lineat(0) scatter qfitci lfitopts(stdp level(95) n(100) ciplot(rline) clpattern(dash) clwidth(medium) clcolor(black) alcolor(black) alpattern(shortdash) alwidth(medium)) histopts(bin(30)) graphopts(legend(off) xtitle("Normalized population (RV)") xline(0, lpattern(solid) lwidth(medthick)) ytitle("P(# corruption episodes > 0)") plotregion(lcolor(black)))		// manual RD plot (quadratic fit)


reg avg_income i.fpm_binary##c.pop_norm if abs(pop_norm) < 822.874			 // balance test 1

reg literacy_rate i.fpm_binary##c.pop_norm if abs(pop_norm) < 822.874		 // balance test 2

reg urbanization_rate i.fpm_binary##c.pop_norm if abs(pop_norm) < 822.874	 // balance test 3

cmogram avg_income pop_norm if abs(pop_norm) < 822.874, cutpoint(0) lineat(0) scatter lfitci lfitopts(stdp level(95) n(100) ciplot(rline) clpattern(dash) clwidth(medium) clcolor(black) alcolor(black) alpattern(shortdash) alwidth(medium)) histopts(bin(30)) graphopts(legend(off) xtitle("Normalized population (RV)") xline(0, lpattern(solid) lwidth(medthick)) ytitle("Monthly avg. income {it:per capita} (Reais)") plotregion(lcolor(black)))			 // balance test 1 plot

graph save bal_test_1.gph, replace

cmogram literacy_rate pop_norm if abs(pop_norm) < 822.874, cutpoint(0) lineat(0) scatter lfitci lfitopts(stdp level(95) n(100) ciplot(rline) clpattern(dash) clwidth(medium) clcolor(black) alcolor(black) alpattern(shortdash) alwidth(medium)) histopts(bin(30)) graphopts(legend(off) xtitle("Normalized population (RV)") xline(0, lpattern(solid) lwidth(medthick)) ytitle("Houses in urban areas (%)") plotregion(lcolor(black)))			 // balance test 2 plot

graph save bal_test_2.gph, replace

cmogram urbanization_rate pop_norm if abs(pop_norm) < 822.874, cutpoint(0) lineat(0) scatter lfitci lfitopts(stdp level(95) n(100) ciplot(rline) clpattern(dash) clwidth(medium) clcolor(black) alcolor(black) alpattern(shortdash) alwidth(medium)) histopts(bin(30)) graphopts(legend(off) xtitle("Normalized population (RV)") xline(0, lpattern(solid) lwidth(medthick)) ytitle("Literate people > 20 y.o. (%)") plotregion(lcolor(black)))			 // balance test 3 plot

graph save bal_test_3.gph, replace

gr combine bal_test_1.gph bal_test_2.gph bal_test_3.gph, row(1)		// combine the 3 saved plots in one

erase bal_test_1.gph
erase bal_test_2.gph
erase bal_test_3.gph


// effect size by bandwidth plot
cap ssc install parmest
{

forv i = 150 (5) 3350 {
	
	qui reg corruption_n i.fpm_binary##c.pop_norm if abs(pop_norm) < `i'
	
	parmest, label level(90 95) list(parm estimate min95 max95 p) escal(N) saving(est_`i', replace)
	
}

preserve

	rdbwselect corruption_n pop_norm, c(0) p(1) kernel(uniform)
	
	local bdw: di `e(h_mserd)'

	use "est_150.dta", clear
	
	gen pop_norm = 150
	
	erase "est_150.dta"

	forv i=155(5)3350 {
		
		append using "est_`i'", gen(app)
		
		replace pop_norm=`i' if app==1
		
		drop app
		
		erase "est_`i'.dta"
	}

	keep if parm=="1.fpm_binary"

	tostring es_1, replace
	
	labmask pop_norm, values(es_1) 

	twoway (line estimate pop_norm, lcolor(black) lwidth(medthick) xaxis(1)) /*
	*/ (rline min95 max95 pop_norm, lcolor(black) lwidth(thin) lpattern(solid)) /*
	*/ (line estimate pop_norm, lcolor(black) lwidth(none) mlwidth(none) xaxis(2)) /*
	*/ , legend(order(1 "`=ustrunescape("\u03C1\u0302")'" 2 "95% C.I.") position(4) ring(0) region(fcolor(none))) /*
	*/ ytitle("") ylabel(-.5 (.25) .5, labsize(small) format(%9.2fc) grid glwidth(vvvthin) glcolor(black)) yline(0, lpattern(solid) lwidth(medium) lcolor(cranberry)) /*
	*/ xtitle("Normalized population (RV)", axis(1)) xlabel(150 (200) 3350, nogrid angle(45) labsize(small)) xline(`bdw', lpattern(dash) lwidth(medium) lcolor(black) axis(2)) /*
	*/ xtitle("Sample size", axis(2)) xlabel(150 (200) 3350, valuelabel nogrid angle(45) labsize(small) axis(2)) plotregion(lcolor(black))

restore
}



*****************************************************************
*** Fuzzy Regression Discontinuity Design ***********************
*****************************************************************

twoway (scatter fpm_hat pop, msize(tiny) mcolor(cranberry)) /*
*/ (lowess fpm_hat pop if inrange(pop, 6793, 10188), mean lcolor(black) lwidth(thick)) /*
*/ (lowess fpm_hat pop if inrange(pop, 10189, 13584), mean lcolor(black) lwidth(thick)) /*
*/ (lowess fpm_hat pop if inrange(pop, 13585, 16980), mean lcolor(black) lwidth(thick)) /*
*/ (lowess fpm_hat pop if inrange(pop, 16981, 23772), mean lcolor(black) lwidth(thick)) /*
*/ (lowess fpm_hat pop if inrange(pop, 23773, 30564), mean lcolor(black) lwidth(thick)) /*
*/ (lowess fpm_hat pop if inrange(pop, 30565, 37356), mean lcolor(black) lwidth(thick)) /*
*/ (lowess fpm_hat pop if inrange(pop, 37357, 44148), mean lcolor(black) lwidth(thick)) /*
*/ (lowess fpm_hat pop if inrange(pop, 44149, 50940), mean lcolor(black) lwidth(thick)) /*
*/  , xlabel(10189 13585 16981 23773 30565 37357 44149, angle(45)) xline(10189 13585 16981 23773 30565 37357 44149, lpattern(solid) lwidth(medium)) legend(off) plotregion(lcolor(black)) /*
*/  xtitle("Population") ytitle("Theoretical FPM transfers (100k reais)")

graph save sharp_disc.gph

twoway (scatter fpm pop, msize(tiny) mcolor(cranberry)) /*
*/ (lowess fpm pop if inrange(pop, 6793, 10188), mean lcolor(black) lwidth(thick)) /*
*/ (lowess fpm pop if inrange(pop, 10189, 13584), mean lcolor(black) lwidth(thick)) /*
*/ (lowess fpm pop if inrange(pop, 13585, 16980), mean lcolor(black) lwidth(thick)) /*
*/ (lowess fpm pop if inrange(pop, 16981, 23772), mean lcolor(black) lwidth(thick)) /*
*/ (lowess fpm pop if inrange(pop, 23773, 30564), mean lcolor(black) lwidth(thick)) /*
*/ (lowess fpm pop if inrange(pop, 30565, 37356), mean lcolor(black) lwidth(thick)) /*
*/ (lowess fpm pop if inrange(pop, 37357, 44148), mean lcolor(black) lwidth(thick)) /*
*/ (lowess fpm pop if inrange(pop, 44149, 50940), mean lcolor(black) lwidth(thick)) /*
*/  , xlabel(10189 13585 16981 23773 30565 37357 44149, angle(45)) xline(10189 13585 16981 23773 30565 37357 44149, lpattern(solid) lwidth(medium)) legend(off) plotregion(lcolor(black)) /*
*/  xtitle("Population") ytitle("Actual FPM transfers (100k reais)")

graph save fuzzy_disc.gph

gr combine sharp_disc.gph fuzzy_disc.gph, col(2)		// combine the 2 saved plots in one

erase sharp_disc.gph
erase fuzzy_disc.gph


cap ssc install reghdfe

egen region=group(regions)

reg fpm fpm_hat c.pop##c.pop##c.pop i.term i.region, r cluster(id_city)		// first stage

scalar fs = r(table)["b","fpm_hat"]

// reghdfe fpm fpm_hat c.pop##c.pop##c.pop, absorb(term regions) vce(cluster id_city)	// OLS regression with high-dimensional fixed effects

reg corruption_n fpm_hat c.pop##c.pop##c.pop i.term i.region, r cluster(id_city)		// reduced-form

scalar rf = r(table)["b","fpm_hat"]

cap ssc install ivreg2

cap ssc install ranktest



*****************************************************************
*** Two-Stage Least Squares estimation (Instrumental Variables) *
*****************************************************************

ivreg2 corruption_n c.pop##c.pop##c.pop (fpm = fpm_hat) i.term i.region, r cluster(id_city) first		// TSLS estimation

display "TSLS coeff. is the ratio of the reduced-form coeff., " rf " to the first-stage coeff., " fs " = " rf/fs

cap net install tf, force from(http://www.princeton.edu/~davidlee/wp/)

tf corruption_n c.pop##c.pop##c.pop (fpm = fpm_hat) i.term i.region, r cluster(id_city) first		// TSLS estimation with valid t-ratios for inference



