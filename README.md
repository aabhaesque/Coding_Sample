
**Author:** Aabha Kandhare  
**Writing Sample:** _Gendered Effects of Drought on Agricultural Employment: Evidence from Rural India_

## Project Overview

This repository contains a fully reproducible Stata pipeline that replicates the main empirical results of my writing sample.

## Note on Data 

Because the raw Periodic Labour Force Survey (PLFS) data and IMD gridded rainfall data are massive and subject to access restrictions, I have included a Python script (`generate_dummy_data.py`) that generates synthetic `.csv` files that perfectly mirror the structure, variable names, and missing-value patterns of the real data.

## Directory Structure

Yale_Predoc_Coding_Sample/  
│  
├── README.md <- This file   
├── generate_dummy_data.py <- Script to generate synthetic datasets  
│  
├── code/  
│ ├── 00_[master.do](https://master.do/) <- Master script (executes the pipeline)  
│ ├── 01_clean_[data.do](https://data.do/) <- Merges data, cleans, and constructs variables  
│ └── 02_[analysis.do](https://analysis.do/) <- Runs regressions and exports tables  
│  
├── data/ <- Where the Python script saves the dummy data  
│  
└── output/ <- Where Stata saves logs and LaTeX tables

## How to Run the Pipeline

**Step 1: Generate the Data**  
Open your terminal (or command prompt), navigate to this main folder, and run:  
python generate_dummy_data.py  
_This will populate the `data/` folder with the required raw datasets._

**Step 2: Update the Path**  
Open Stata and open `code/00_master.do`. Change the `global root` path to match the location of this folder on your computer:  
global root "/Users/YourUsername/Desktop/Yale_Predoc_Coding_Sample"

**Step 3: Execute**  
Run the entire `00_master.do` file.

The pipeline will automatically clean the data, run the regressions, save a log file, and export formatted LaTeX tables to the `output/tables/` folder.

---

## Alignment with the Writing Sample

Every step in the Stata code is explicitly mapped to the methodology described in the attached PDF:

### `01_clean_data.do` (Data Engineering)

- **Section 2.1 (Data):** Restricts the sample to rural individuals in agricultural households.
    
- **Section 2.2 (Outcomes):** Constructs the binary `agri_cws` outcome and the 4-way mutually exclusive employment decomposition (`is_self_employed`, `is_unpaid_family`, etc.).
    
- **Section 2.4 (Treatment):** Defines `drought` (and `flood`) using historical percentile thresholds.
    
- **Section 2.6 (Controls):** Constructs age-squared and interaction terms.
    
- **Robust Data Merging:** Demonstrates a robust three-stage `m:1` merge. It merges HH+Person files, maps changing district codes using a crosswalk, and attaches district-season climate data. It uses `_merge` indicators to explicitly inspect and document data loss at every step.
    

### `02_analysis.do` (Empirical Strategy & Results)

- **Section 3 (Empirical Strategy):** Estimates the two-way fixed effects (TWFE) model using `reghdfe`, absorbing district and year-season fixed effects, with standard errors clustered at the district level (`vce(cluster district_id)`).
    
- **Section 4.1 (Table 2):** Replicates the main results table (No controls -> + Individual -> + Household).
    
- **Section 4.2 (Table 3):** Runs the `foreach` loop to estimate the 4-way decomposition, and performs the exact internal consistency check mentioned in the text (verifying that the coefficients sum to approximately zero within each gender).
