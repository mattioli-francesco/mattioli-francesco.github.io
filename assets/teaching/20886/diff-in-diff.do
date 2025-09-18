*** Replication of **********************************************
*** Card and Kruger (1994) Minimum Wages and Employment: ********
*** A Case Study of the Fast-Food Industry in Nej Jersey and ****
*** Pennsylvania. American Economic Review **********************
*** https://www.aeaweb.org/articles?id=10.1257/aer.90.5.1397 ****
*** modified data and code from: ********************************
*** https://www.ssc.wisc.edu/~bhansen/econometrics/ *************

clear all													// clear STATA memory and get ready to start a new project

cd "/Users/francescomattioli/Library/CloudStorage/OneDrive-UniversitàCommercialeLuigiBocconi/PhD/TA/20886 – Foundations of Social Sciences/"							// set working directory to a familiar location


*****************************************************************
*** Difference-in-Differences (2 groups, 2 periods) *************
*****************************************************************

use "CK_AER1994_mod.dta", clear								// load the dataset

gen time = ym(year, month)

format %tm time

tab state_str

gen state = (state_str == "New Jersey") if state_str != ""

gen fte_workers = ft_workers + pt_workers / 2 + managers 	// number of full-time equivalent workers (sum of full-time, half of part-time, and managers)

drop if fte_workers == .

bys store: egen n_periods = count(1)

keep if n_periods == 2

table time state, stat(mean fte_workers)					// 2x2 table of mean outcomes

scalar diff_NJ = 20.89725 - 20.43058						// difference in the treated state

scalar diff_PN = 21.09667 - 23.38							// difference in the control state

display "The diffence-in-differences amounts to: " diff_NJ - diff_PN

reg fte_workers i.time##i.state								// diff-in-diff estimation

preserve

	collapse (mean) fte_workers, by(state time)
	
	twoway (line fte_workers time if state==1) || (line fte_workers time if state==0), xlabel(, nogrid)	xline(387, lpattern(dash) lwidth(medthick)) legend(order(1 "New Jersey" 2 "Pennsylvania") position(2) ring(0) region(fcolor(none))) ytitle("Avg. full-time equivalent workers") plotregion(lcolor(black))				// diff-in-diff plot

restore


*****************************************************************
*** Diff-in-Diff (N groups, N periods, staggered treatment) *****
*****************************************************************

use "event_study.dta", clear

sort unit year

reghdfe outcome treat_lead5 treat_lead4 treat_lead3 treat_lead2 treat_lead1 treat_0 treat_lag1 treat_lag2 treat_lag3 treat_lag4 treat_lag5plus, absorb(year unit)	// diff-in-diff estimation

// intervention occurs at time 0
replace treat_lead1 = 0

reghdfe outcome treat_lead5 treat_lead4 treat_lead3 treat_lead2 treat_lead1 treat_0 treat_lag1 treat_lag2 treat_lag3 treat_lag4 treat_lag5plus, absorb(year unit)	// event study regression

estimates store leads_lags		// store regression results

coefplot leads_lags, keep(treat_lead5 treat_lead4 treat_lead3 treat_lead2 treat_lead1 treat_0 treat_lag1 treat_lag2 treat_lag3 treat_lag4 treat_lag5plus) vertical yline(0, lcolor(cranberry) lwidth(medthick) lpattern(solid)) xline(5, lcolor(black)) ciopts(lwidth(*3) lcolor(black)) mcolor(black) xlabel(, angle(45)) omitted			// event-study plot


