import pandas as pd
import numpy as np
import os

np.random.seed(42)

# 1. Household Data (dummy data for HHV1)
hh = pd.DataFrame({
    'hh_id': np.arange(1, 501),
    'hh_type': np.random.choice(['Self_employed_Agri', 'Casual_Agri_Labour', 'Regular_Wage'], 500),
    'sc_st_status': np.random.choice([1, 2, 3, 4], 500),
    'plfs_dist_code': np.random.randint(1, 51, 500)
})
hh.to_csv('data/hh_raw.csv', index=False)

# 2. Person Data (dummy data for PerV1)
person = pd.DataFrame({
    'person_id': np.arange(1, 2001),
    'hh_id': np.random.choice(hh['hh_id'], 2000),
    'year': np.random.choice([2018, 2019], 2000),
    'season': np.random.choice(['Kharif', 'Rabi', 'Zaid'], 2000),
    'sex': np.random.choice([1, 2], 2000),
    'age': np.random.randint(15, 61, 2000),
    'agri_cws': np.random.choice([0, 1], 2000, p=[0.5, 0.5]),
    'agri_breakdown': np.random.choice(['Self_employed_cultivator', 'Unpaid_family_worker', 'Casual_wage_labour_agri', 'Not_in_agriculture'], 2000),
    'education_cat': np.random.choice([1, 2, 3, 4], 2000),
    'marital_status': np.random.choice([1, 2, 3, 4], 2000)
})
person.to_csv('data/person_raw.csv', index=False)

# 3. Crosswalk
crosswalk = pd.DataFrame({
    'plfs_dist_code': np.arange(1, 51),
    'climate_dist_code': np.arange(101, 151)
})
crosswalk.to_csv('data/crosswalk.csv', index=False)

# 4. Climate Data (50 districts * 2 years * 3 seasons = 300 rows)
climate = pd.DataFrame({
    'climate_dist_code': np.repeat(np.arange(101, 151), 6),
    'year': np.tile(np.repeat([2018, 2019], 3), 50),
    'season': np.tile(['Kharif', 'Rabi', 'Zaid'], 100),
    'rainfall': np.random.normal(50, 15, 300),
    'p20_historical': np.random.normal(40, 5, 300),
    'p80_historical': np.random.normal(60, 5, 300)
})
climate.to_csv('data/climate_raw.csv', index=False)

print("Dummy datasets generated.")