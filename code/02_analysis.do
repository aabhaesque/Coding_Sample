* Project: Gendered Effects of Drought on Agricultural Employment
                              * Analysis and Regressions*

    use "$data/clean_data.dta", clear
    
    eststo clear
    
    local controls "age age_sq i.education_cat i.marital_status i.sc_st_status" //Local macro for the controls to keep the regression syntax clean
    
    *  Regression Results (Matches Paper Table 2)
    * -------------------------------------------------------------------------
    
    * Column (1): No controls
    eststo col1: reghdfe agri_cws drought flood female drought_x_female flood_x_female, ///
        absorb(district_id year_season) vce(cluster district_id)
        
    * Column (2): + Individual controls
    eststo col2: reghdfe agri_cws drought flood female drought_x_female flood_x_female ///
        age age_sq i.education_cat i.marital_status, ///
        absorb(district_id year_season) vce(cluster district_id)
        
    * Column (3): + Household controls (SC/ST)
    eststo col3: reghdfe agri_cws drought flood female drought_x_female flood_x_female `controls', ///
        absorb(district_id year_season) vce(cluster district_id)

    * Export Table 2 to LaTeX (Matches Paper Table 2 format)
    esttab col1 col2 col3 using "$output/tables/table2_main.tex", replace ///
        keep(drought drought_x_female flood flood_x_female female) ///
        order(drought drought_x_female flood flood_x_female female) ///
        b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
        stats(N r2, labels("Observations" "R-squared")) ///
        mtitles("No controls" "+ Individual" "+ Household") ///
        label booktabs
        
    * -------------------------------------------------------------------------
    * Employment Type Decomposition (Matches Paper Table 3)
    * -------------------------------------------------------------------------
    eststo clear
    
    * Loop through the 4 mutually exclusive outcomes and run a separate LPM for each
    foreach outcome in is_self_employed is_unpaid_family is_casual_labour is_not_in_agri {
        eststo `outcome': reghdfe `outcome' drought flood female drought_x_female flood_x_female `controls', ///
            absorb(district_id year_season) vce(cluster district_id)
    }
    
    * Export Table 3 to LaTeX
    esttab is_self_employed is_unpaid_family is_casual_labour is_not_in_agri using "$output/tables/table3_decomp.tex", replace ///
        keep(drought drought_x_female) ///
        b(4) se(4) star(* 0.10 ** 0.05 *** 0.01) ///
        stats(N, labels("Observations")) ///
        mtitles("Self-Emp" "Unpaid Family" "Casual Labour" "Not in Agri") ///
        label booktabs
        
    * -------------------------------------------------------------------------
    * INTERNAL CONSISTENCY CHECK (Matches Paper Section 4.2 text)
    * "the four coefficients sum to approximately zero within each gender"
    * -------------------------------------------------------------------------
 
    * To verify that the coefficients sum to zero, we extract the drought_x_female coefficient from each model and sum them
    
    quietly est restore is_self_employed
    local b1 = _b[drought_x_female]
    
    quietly est restore is_unpaid_family
    local b2 = _b[drought_x_female]
    
    quietly est restore is_casual_labour
    local b3 = _b[drought_x_female]
    
    quietly est restore is_not_in_agri
    local b4 = _b[drought_x_female]
    
    local sum_female = `b1' + `b2' + `b3' + `b4'
    display "Sum of Drought x Female coefficients across 4 categories: " %9.6f `sum_female'
    display "Expected to be approximately zero (internal consistency check)."
