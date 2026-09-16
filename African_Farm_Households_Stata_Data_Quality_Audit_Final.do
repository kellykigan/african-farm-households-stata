*******************************************************
* AGRICULTURAL SURVEY OF AFRICAN FARM HOUSEHOLDS
* Reproducible Stata Data Quality Audit
* Author: Kelly Kigan
*******************************************************

version 17.0
clear all
set more off

*------------------------------------------------------*
* 1. PROJECT PATHS
*------------------------------------------------------*
global project "/Users/kellykigan/Documents/African_Farm_Households_Stata"
global raw    "$project/raw"
global clean  "$project/clean"
global graphs "$project/graphs"
global output "$project/output"

capture mkdir "$clean"
capture mkdir "$graphs"
capture mkdir "$output"

*------------------------------------------------------*
* 2. LOG
*------------------------------------------------------*
capture log close
log using "$output/01_data_quality_audit.log", replace text

*------------------------------------------------------*
* 3. IMPORT RAW DATA
*------------------------------------------------------*
import delimited ///
    "$raw/Agricultural Survey of African Farm Households.csv", ///
    clear encoding("ISO-8859-1") varnames(1)

*------------------------------------------------------*
* 4. INITIAL DATA STRUCTURE
*------------------------------------------------------*
count
describe

* Explore major variable groups
ds
ds hh*
ds age*
ds educ*
ds farm*
ds inc*
ds dist*

*------------------------------------------------------*
* 5. HOUSEHOLD IDENTIFIER
*------------------------------------------------------*
describe hhcode
codebook hhcode
count if missing(hhcode)
isid hhcode
duplicates report hhcode
duplicates list hhcode

*------------------------------------------------------*
* 6. GEOGRAPHIC STRUCTURE
*------------------------------------------------------*
describe adm0 adm1 adm2
codebook adm0
codebook adm1
tabulate adm0, missing

encode adm0, generate(country_id)
label variable country_id "Country"
tabulate country_id, missing

*------------------------------------------------------*
* 7. VARIABLE TYPES
*------------------------------------------------------*
ds, has(type numeric)
ds, has(type string)

describe clmadaptstrategy1

*------------------------------------------------------*
* 8. MISSING-DATA AUDIT
*------------------------------------------------------*
misstable summarize

misstable summarize ///
    hhsize age1 educ1 gender1 ///
    farmtype fplots ///
    incfarm incnfarm ///
    distpmktkm distsmktkm ///
    extc hhelectric

*------------------------------------------------------*
* 9. KEY CATEGORICAL VARIABLES
*------------------------------------------------------*
codebook gender1
codebook educ1
codebook farmtype
codebook extc
codebook tenure1

tabulate hhsize, missing
tabulate age1, missing
tabulate educ1, missing
tabulate extc, missing

*------------------------------------------------------*
* 10. HOUSEHOLD SIZE: PLAUSIBILITY CHECK
*------------------------------------------------------*
summarize hhsize, detail
tabulate hhsize, missing

* Flag extreme values for investigation; do not delete
gen hhsize_outlier = hhsize > 50 if !missing(hhsize)
label variable hhsize_outlier "Household size greater than 50"
tabulate hhsize_outlier, missing

list hhcode adm0 hhsize if hhsize_outlier == 1

* Retain original variable and create analytical version
gen hhsize_clean = hhsize
replace hhsize_clean = . if hhsize_outlier == 1
label variable hhsize_clean ///
    "Household size with flagged extreme values set to missing"

*------------------------------------------------------*
* 11. AGE: PLAUSIBILITY CHECK
*------------------------------------------------------*
summarize age1, detail
tabulate age1, missing

count if age1 < 15 & !missing(age1)
count if age1 > 100 & !missing(age1)

list hhcode adm0 age1 ///
    if (age1 < 15 | age1 > 100) & !missing(age1)

*------------------------------------------------------*
* 12. FARMING EXPERIENCE: PLAUSIBILITY CHECK
*------------------------------------------------------*
summarize farmingexperience, detail

gen experience_outlier = ///
    farmingexperience > 80 if !missing(farmingexperience)

label variable experience_outlier ///
    "Farming experience greater than 80 years"

tabulate experience_outlier, missing

list hhcode adm0 age1 farmingexperience ///
    if experience_outlier == 1

*------------------------------------------------------*
* 13. FARM INCOME
*------------------------------------------------------*
summarize incfarm, detail

histogram incfarm, ///
    title("Distribution of Farm Income") ///
    name(hist_incfarm, replace)

graph export "$graphs/histogram_incfarm.png", replace width(1800)

* Log transformation; +1 retains zero-income observations
gen ln_farm_income = ln(incfarm + 1) if incfarm >= 0
label variable ln_farm_income "Log farm income (+1)"

histogram ln_farm_income, ///
    title("Distribution of Log Farm Income") ///
    name(hist_ln_farm_income, replace)

graph export "$graphs/histogram_ln_farm_income.png", replace width(1800)

*------------------------------------------------------*
* 14. FARM AREA
*------------------------------------------------------*
summarize fplotarea1 fplotarea2 fplotarea3, detail

egen n_area_parts = rownonmiss( ///
    fplotarea1 fplotarea2 fplotarea3)

egen farm_area_total = rowtotal( ///
    fplotarea1 fplotarea2 fplotarea3)

* Avoid treating all-missing components as zero
replace farm_area_total = . if n_area_parts == 0

label variable farm_area_total "Total reported farm area"
summarize farm_area_total, detail

graph box farm_area_total, ///
    title("Reported Farm Area") ///
    name(box_farm_area, replace)

graph export "$graphs/box_farm_area_total.png", replace width(1800)

*------------------------------------------------------*
* 15. MARKET ACCESS
*------------------------------------------------------*
summarize distpmktkm distsmktkm, detail

graph box distpmktkm, ///
    title("Distance to Purchase Market") ///
    name(box_dist_purchase, replace)

graph export "$graphs/box_distance_purchase_market.png", replace width(1800)

graph box distsmktkm, ///
    title("Distance to Selling Market") ///
    name(box_dist_sell, replace)

graph export "$graphs/box_distance_selling_market.png", replace width(1800)

gen ln_dist_buy = ln(distpmktkm + 1) if distpmktkm >= 0
gen ln_dist_sell = ln(distsmktkm + 1) if distsmktkm >= 0

label variable ln_dist_buy "Log distance to purchase market (+1)"
label variable ln_dist_sell "Log distance to selling market (+1)"

*------------------------------------------------------*
* 16. MISSINGNESS BY COUNTRY
*------------------------------------------------------*
tabulate country_id, missing
tabulate country_id extc, row missing
tabulate country_id farmtype, row missing

gen income_missing = missing(incfarm)
label variable income_missing "Farm income is missing"
tabulate country_id income_missing, row

*------------------------------------------------------*
* 17. SAVE ANALYTICAL FOUNDATION
*------------------------------------------------------*
save "$clean/02_quality_checked_data.dta", replace

log close

display "Data quality audit completed successfully."
