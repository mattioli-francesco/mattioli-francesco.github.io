// access the European Social Survey data portal at https://ess-search.nsd.no
// select ESS round 10
// find the international codebook at https://stessrelpubprodwe.blob.core.windows.net/data/round10/fieldwork/source/ESS10_source_questionnaires.pdf
// find the Italian codebook (important for details about country-specific questions) at https://stessrelpubprodwe.blob.core.windows.net/data/round10/fieldwork/italy/ESS10_questionnaires_IT.pdf
// download the dataset "ESS10 - integrated file, edition 3.1" in STATA format (.dta) after registering to the website
// store the dataset into a proper location on your laptop

clear all	// remove from memory all data from previous sessions

cd "/Users/francescomattioli/Library/CloudStorage/OneDrive-UniversitàCommercialeLuigiBocconi/PhD/TA/20612 – Political Science/stata"	// set the working directory to the specified location

//log using discrete_choice_models.smcl, replace	// open a log file to record all commands and output during the STATA session

use "ESS10/ESS10_mod.dta"	// load a Stata-format dataset (.dta) into memory

// We want to study the socio-demographic determinants of voter participation among Italians

// Finding variables of interest:
// - read the codebook provided with the dataset
// - explore variables using STATA's data screening commands
// - type keywords in the variable list (on the right of STATA's interface) and explore the variables retained

// We are interested in variable "vote"

describe vote				// provide a basic description of variables (i.e. name, type, format, label)

summarize vote				// provide descriptive statistics of numeric variables (i.e. number of observations, mean, standard deviation, minimum and maximum)
summarize vote, detail		// provide additional statistics (i.e. variance, skewness, kurtosis, a series of percentiles, and the 4 smallest and largest values)

tabulate vote				// provide a frequency table of (categorical) variables
tabulate vote, nolabel		// hide value labels (if available) and show only the underlying values



**********************************************
************ Binary choice models ************
**********************************************

ssc install fre				// install a package to do both at the same time, while also showing missing data codes
fre vote					// provide a frequency table with both values and labels for all variables (20 bottom and top values)

codebook vote				// provide a thorough description of variables (i.e. type, label, range, unique values, number of missing, examples of values/frequency table)

// Is vote a suitable binary variable?
// Does the order of codes align with the direction of the research question?

recode vote (2 = 0) (3/.z = .), generate(turnout)	// create a new variable named "turnout" that changes values of vote by (i) reversing the direction of codes (such that a higher value corresponds to voter participation rather than the opposite); and (ii) changing irrelevant values into missing values (missing values in STATA are indicated by . or by .a, ..., .z – in case the kind of missing has a particular meaning; in STATA the following series of inequalities is true: 0 < 1 < ... < 9999999 < . < .a < ... < .z)

tabulate vote turnout, missing				// check if the new variable takes the values we wanted through a 2-way frequency table
label variable turnout "Turnout (binary)"	// Assign our new variable a unique variable label
label define turnout_labels 0 "No" 1 "Yes"	// previous value labels were not copied to the new variable: create custom value labels named "turnout_labels"
label values turnout turnout_labels			// attach the new values labels to our variable 

// Let's choose some covariates of interest, e.g. age, gender, education, and income
// Clean them in the same way, but more quickly

clonevar age = agea if agea < .					// age
clonevar gender = gndr							// gender (no need to clean it)
clonevar educ_years = eduyrs	if eduyrs <= 30		// years of education (few very high values – outliers?)
clonevar income_d = hinctnta if hinctnta < .	// deciles of household net income

// Let's focus on Italy

keep if cntry=="IT"								// retain only Italian respondents (same as "drop if cntry!="IT""); careful! This operation cannot be undone, but you must restart

dropmiss, force									// get rid of variables that have all missing missing values on the subset of respondents retained

// factor-variable notation (essential for interactions):
// - prefix i. before a categorical variable specifies indicators for each category of the variable
// - prefix c. before a continous variable informs STATA not to specify indicators for each category when interactions are being added to models
// more info "help fvvarlist"

summarize i.turnout age i.gender educ_years i.income_d, vsquish



**********************************************
********** Linear Probability Model **********
**********************************************

regress turnout age i.gender educ_years i.income_d

predict turnout_pr if e(sample) == 1, xb	// compute predicted probabilities; why is it important to specify "if e(sample) == 1"?

hist turnout_pr, xline(0 1, lcolor(red))	// check visually the distribution of predicted probabilities

capture count if (turnout_pr < 0 | turnout_pr > 1) & turnout_pr != .		// count how many observations have a predicted probability outside the unit interval; why is it important to specify "& turnout_pr != ."?
display "LPM predictions outside unit interval: `r(N)'"						// displayed number is not 0, hence one of the problems of LPM

summarize turnout_pr						// look at the maximum: an individual with a specific combination of covariates is predicted to have a probability of voting of 104% (?!)

browse turnout turnout_pr age gender educ_years income_d if (turnout_pr < 0 | turnout_pr > 1) & turnout_pr != .	// check visually which observations have which values of covariates that lead to unrealistic predictions

rvfplot										// check homoskedasticity through a redisuals-versus-fitted plot; not easy to be visually detected when variables involved are discrete
estat hettest								// Breusch-Pagan heteroskedasticity test; we wish not to reject (H0: constant variance) but we do, hence another problem of LPM

regress turnout age i.gender educ_years i.income_d, vce(robust)			// adjust standard errors for heteroskedasticity (generally they get larger); or simply "regress ... , r"

margins, dydx(*)							// marginal effects of each variable; identical to OLS coefficients in LPM



**********************************************
**************** Interactions ****************
**********************************************
regress turnout c.age##c.educ_years			// case 1: continuous * continuous; same as "regress turnout age educ_years c.age#c.educ_years"

sum educ_years if e(sample), detail			// pick a few meaningful values of educ_years in the estimation sample to produce a graph (e.g. 25th, 50th and 75th percentiles)
margins, at(age=(18(10)90) educ_years=(8 13 15))		// predicted values of turnout for each combination of the variables' levels specified
marginsplot, recastci(rarea) legend(title("Education years") order(1 "1st quartile" 2 "median" 3 "3rd quartile"))
graph export "fig_01.eps", replace


regress turnout i.gender##c.educ_years		// case 2: continuous * categorical; same as "regress turnout gender educ_years i.gender#c.educ_years"

sum educ_years if e(sample), detail			// pick a few meaningful values of educ_years in the estimation sample to produce a graph (e.g. 25th, 50th and 75th percentiles)
margins i.gender, at(educ_years=(0(3)28))		// predicted values of turnout for each combination of the variables' levels specified
marginsplot, recastci(rarea) legend(title("Gender"))
graph export "fig_02.eps", replace


regress turnout i.gender##i.income_d		// case 3: categorical * categorical; same as "regress turnout gender i.income_d i.gender#i.income_d"

margins i.income_d#i.gender					// predicted values of turnout for each combination of the variables' levels specified
marginsplot, xlabel(, angle(45)) legend(title("Gender"))
graph export "fig_03.eps", replace



**********************************************
******************* Logit ********************
**********************************************
logit turnout age i.gender educ_years i.income_d			// default logit estimation: coefficients are betas

logit turnout age i.gender educ_years i.income_d, or 		//logit estimation with odds ratios reported: coefficients are exp{betas}

logistic turnout age i.gender educ_years i.income_d			// identical to logit ..., or

margins, dydx(*)					// average marginal effects of each variable

margins, dydx(*) atmeans			// marginal effects of each variable for the average individual

margins, dydx(*) at(age = 30 gender = 1 educ_years = 10 income_d = 4)			// marginal effects of each variable for a representative individual (e.g. 30-year-old woman with 10 years of education and income in 4th decile)

margins i.gender i.income_d			// predicted probabilities for all levels of categorical variables gender and income_d
margins, at(age = (18(10)88))			// predicted probabilities at specified values of continuous variables age

**********************************************
****************** Probit ********************
**********************************************

probit turnout age i.gender educ_years i.income_d			// probit model estimation

margins, dydx(*)					// average marginal effects of each variable

margins, dydx(*) atmeans			// marginal effects of each variable for the average individual

margins, dydx(*) at(age = 30 gender = 1 educ_years = 10 income_d = 4)			// marginal effects of each variable for a representative individual (e.g. 30-year-old woman with 10 years of education and income in 4th decile)

margins i.gender i.income_d			// predicted probabilities for all levels of categorical variables gender and income_d
margins, at(educ_years = (0(5)25))			// predicted probabilities at specified values of continuous variables educ_years


**********************************************
*** Copmparison of predicted probabilities ***
**********************************************

logit turnout educ_years
predict pr_logit						// probabilities Lambda(x'beta) for each observation predicted by the logit model
probit turnout educ_years
predict pr_probit						// probabilities Phi(x'beta) for each observation predicted by the probit model
regress turnout educ_years
predict pr_ols							// probabilities x'beta for each observation predicted by the linear model					

sort educ_years							// (just to get a nice graph later)

twoway (line pr_logit educ_years, lwidth(medthick)) (line pr_probit educ_years, lwidth(medthick)) (line pr_ols educ_years, lwidth(medthick) lcolor(orange*.6)) (scatter turnout educ_years, msize(tiny) mcolor(black) jitter(8)), legend(on order(1 "Logit prediction" 2 "Probit prediction" 3 "Linear prediction" 4 "Observed turnout") region(fcolor(none)) position(3) ring(0)) plotregion(lcolor(black))
graph export "fig_05.eps", replace



**********************************************
************* Multinomial models *************
**********************************************

fre prtvtdit							// categorical variable recording the party voted in the last general elections (2018); parties are not sorted in any particular order; many of them were just voted by a few respondents

generate coalition = .					// create a new variable that aggregates parties according to coalition (center-left, center-right, five star, others)
replace coalition = 1 if inlist(prtvtdit,2,7,11,14)		// center-left coalition
replace coalition = 2 if inlist(prtvtdit,3,4,5,8)		// center-right coalition
replace coalition = 3 if inlist(prtvtdit,1)				// five star movement
replace coalition = 4 if coalition== . & prtvtdit < .a	// other minor parties

label variable coalition "Electoral coalition"			// create labels for the new variable following the usual procedure
label define coalition_labels 1 "Center-left" 2 "Center-right" 3 "Five star movement" 4 "Others"
label values coalition coalition_labels

tab prtvtdit coalition					// check that parties have been sorted correctly


// according to official statistics the five star movement got, as a single party, a plurality of votes in 2018; its vote shares were particularly high in Southern and Insular Italy
// let's analyze the probability that respondents from Southern and Insular Italy reported to have voted for different coalitions

fre region								// categorical variable recording the Italian NUTS 1 areas of residence

generate res_south_insular = (region == "ITF" | region == "ITG") if region != ""		// fast way to create a dummy variable
label variable res_south_insular "Southern/Insular resident"



**********************************************
************ Multinomial Logit ***************
**********************************************

mlogit coalition res_south_insular, baseoutcome(1) 			// multinomial logit model; center-left as baseline

mlogit coalition res_south_insular, baseoutcome(1) rrr 		// multinomial logit model with relative-risk-ratios; center-left as baseline

mlogit coalition i.res_south_insular, baseoutcome(3) rrr 		// multinomial logit model with relative-risk-ratios; five star as baseline

margins, dydx(*)											// marginal effects

margins i.res_south_insular									// predicted probabilities of voting for different coalitions for different levels of res_south_insular	
marginsplot, recastci(rarea) legend(title("Coalition voted") order(1 "Center-left" 2 "Center-right" 3 "Five star mov." 4 "Other parties"))
graph export "fig_06.eps", replace


**********************************************
************ Multinomial Probit **************
**********************************************

mprobit coalition res_south_insular, baseoutcome(1) 			// multinomial probit model; center-left as baseline

mprobit coalition res_south_insular, baseoutcome(3) 		// multinomial logit model with relative-risk-ratios; five star as baseline

margins, dydx(*)											// marginal effects


**********************************************
*************** Ordered models ***************
**********************************************

fre polintr										// categorical variable recording interest in politics in descending order

recode polintr (1 = 4) (2 = 3) (3 = 2) (4 = 1)	// reversing the order of answers (higher values correspond to higher interest)

label define interest 1 "Not at all interested" 2 "Hardly interested" 3 "Quite interested" 4 "Very interested"
lab values polintr interest

fre polintr										// check the recoding has been sucessful

ologit polintr educ_years i.coalition			// ordered logit model

ologit polintr educ_years i.coalition, or		// ordinal logit model with odds-ratios

capture findit spost13_ado								// run it and install the first package that appears in the dialogue box

brant											// performs the brant test: a rejection indicates that the parallel odds assumtpion is violated

oprobit polintr educ_years i.coalition			// ordered probit model






// graphs included in the presentation
twoway (function y= .5+x/10, range(-6 6) lwidth(thick) lpattern(dash) lcolor(orange*.6)) || (function y= .5+x/10, range(-5 5) lwidth(thick) lpattern(solid) lcolor(orange*.6)), ytitle("{it:F (x)}") xtitle("{it:x}")ylabel(, nogrid) xlabel(, nogrid) legend(on order(1 "Linear function") region(fcolor(none)) position(3) ring(0)) plotregion(lcolor(black)) yline(0 1)
graph export "fig_04a.eps", replace


twoway (function y= logistic(x), range(-6 6) lwidth(thick) lpattern(solid)) || (function y= .5+x/10, range(-6 6) lwidth(thick) lpattern(dash) lcolor(orange*.6)) || (function y= .5+x/10, range(-5 5) lwidth(thick) lpattern(solid) lcolor(orange*.6)), ytitle("{it:F (x)}") xtitle("{it:x}")ylabel(, nogrid) xlabel(, nogrid) legend(on order(1 "Logistic cdf" 2 "Linear function") region(fcolor(none)) position(3) ring(0)) plotregion(lcolor(black)) yline(0 1)
graph export "fig_04b.eps", replace


twoway (function y= logistic(x), range(-6 6) lwidth(thick) lpattern(solid)) || (function y= normal(x), range(-6 6) lwidth(thick) lpattern(solid)) || (function y= .5+x/10, range(-6 6) lwidth(thick) lpattern(dash) lcolor(orange*.6)) || (function y= .5+x/10, range(-5 5) lwidth(thick) lpattern(solid) lcolor(orange*.6)), ytitle("{it:F (x)}") xtitle("{it:x}")ylabel(, nogrid) xlabel(, nogrid) legend(on order(1 "Logistic cdf" 2 "Std. normal cdf" 4 "Linear function") region(fcolor(none)) position(3) ring(0)) plotregion(lcolor(black)) yline(0 1)
graph export "fig_04c.eps", replace

log close	// save and close the log file
translate discrete_choice_models.smcl discrete_choice_models.pdf, replace




