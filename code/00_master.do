
* Project: Gendered Effects of Drought on Agricultural Employment
* Author: Aabha Kandhare
          *Master do-file to execute the full pipeline*

    * 1. SETUP ENVIRONMENT
    version 17
    clear all
    set more off
    set varabbrev off

    * 2. SET GLOBAL PATHS
    * Change this root path to your local directory before running
    global root "C:/Users/YourUsername/Desktop/Yale_Tobin_Coding_Sample"
    global data   "$root/data"
    global code   "$root/code"
    global output "$root/output"
    
    capture mkdir "$output"
    capture mkdir "$output/logs"
    capture mkdir "$output/tables"

    * 3. LOG THE SESSION
    capture log close
    log using "$output/logs/master_log.smcl", replace

    * 4. INSTALL REQUIRED PACKAGES
    foreach pkg in reghdfe ftools estout {
        capture which `pkg'
        if _rc ssc install `pkg', replace
    }

    * 5. EXECUTE PIPELINE
    * Run generate_dummy_data.py before executing this file.
    
    display "Running Data Cleaning..."
    do "$code/01_clean_data.do"
    
    display "Running Analysis..."
    do "$code/02_analysis.do"

    display "Pipeline Complete."
    log close
