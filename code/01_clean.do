* Project: Gendered Effects of Drought on Agricultural Employment
          * Data pipeline (Merges, Cleaning, and Variables)* 

    * 1. MERGE PLFS HOUSEHOLD AND PERSON DATA
    import delimited using "$data/person_raw.csv", clear
    merge m:1 hh_id using "$data/hh_raw.csv", gen(_merge_hh) //many-one merge used since multiple people may belong to the same household
    tab _merge_hh
    drop if _merge_hh == 1 // drop the people who cannot be matched
    
    * 2. MERGE CROSSWALK (District Harmonization)
	* Crosswalk used because PLFS district codes change across year panels 
    merge m:1 plfs_dist_code using "$data/crosswalk.csv", gen(_merge_cw)
    tab _merge_cw
    drop if _merge_cw == 1
    
    * 3. MERGE CLIMATE DATA
	* We match on climate_dist_code, year, and season (the unit of observation for the shock)
    merge m:1 climate_dist_code year season using "$data/climate_raw.csv", gen(_merge_clim)
    tab _merge_clim
    drop if _merge_clim == 1
    
    drop _merge_hh _merge_cw _merge_clim // Drop the temporary merge variables
    
    * 4. DEFINE TREATMENT (Drought and Flood)
	* Drought is 1 if rainfall is below the 20th percentile of historical distribution; Flood is 1 if rainfall is above the 80th percentile
    
    gen drought = (rainfall < p20_historical) if !missing(rainfall) & !missing(p20_historical)
    gen flood = (rainfall > p80_historical) if !missing(rainfall) & !missing(p80_historical)
    
    * 5. FILTER SAMPLE
	* Restrict sample to rural individuals in agricultural households
    keep if inlist(hh_type, "Self_employed_Agri", "Casual_Agri_Labour")
    drop if missing(drought) | missing(flood) | missing(agri_cws)
    
    * 6. CONSTRUCT CONTROLS
    gen female = (sex == 2) if !missing(sex)
    gen age_sq = age^2 if !missing(age)
    
    * Interactions
    gen drought_x_female = drought * female
    gen flood_x_female = flood * female
    
    * 7. DUMMIES FOR DECOMPOSITION
	* Creates binary indicators for mutually exclusive employment categories
    gen is_self_employed = (agri_breakdown == "Self_employed_cultivator") if !missing(agri_breakdown)
    gen is_unpaid_family = (agri_breakdown == "Unpaid_family_worker") if !missing(agri_breakdown)
    gen is_casual_labour = (agri_breakdown == "Casual_wage_labour_agri") if !missing(agri_breakdown)
    gen is_not_in_agri   = (agri_breakdown == "Not_in_agriculture") if !missing(agri_breakdown)
    
    * 8. CREATE FIXED EFFECT IDENTIFIERS
    rename plfs_dist_code district_id
    gen year_season = string(year) + "_" + season // Combine year and season into a single string for the fixed effect so that reghdfe absorbs it as a single high-dimensional FE
    
    * 9. LABELS AND SAVE
    label var drought "Drought (1=Yes)"
    label var flood "Flood (1=Yes)"
    label var female "Female (1=Yes)"
    label define yesno 0 "No" 1 "Yes"
    label values drought flood female yesno
    
    compress 
    save "$data/clean_data.dta", replace
