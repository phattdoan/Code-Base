# Import physcian compare dataset and add header to the dataset

import pandas as pd
#import pylab as pl
#import numpy as np
#%matplotlib inline
#import matplotlib.pyplot as plt
#import matplotlib.patches as mpatches
#import statsmodels.api as sm


Phys_Comp_raw = pd.read_csv("../assets/Physician_Compare_National_Downloadable_File.csv",
                            header = None, index_col = False, low_memory = False)


Phys_Comp_raw.columns = ['NPI', 'PAC_ID', 'Pro_Enroll_ID',
                         'Last_Name', 'First_Name', 'Mid_Name',
                         'Suffix', 'Gender', 'Credential',
                         'Med_School', 'Grad_Yr', 'Primary_SPC',
                         'Sec_SPC1', 'Sec_SPC2',
                         'Sec_SPC3', 'Sec_SPC4',
                         'Sec_SPC_All', 'Org_Name', 'Org_PAC_ID',
                         'Group_Size', 'Address1', 'Address2',
                         'Address_Marker', 'City', 'State', 'Zip',
                         'Phone', 'Hosp_Affl1', 'Hosp_Affl_Lbn1',
                         'Hosp_Affl2', 'Hosp_Affl_Lbn2',
                         'Hosp_Affl3', 'Hosp_Affl_Lbn3',
                         'Hosp_Affl4', 'Hosp_Affl_Lbn4',
                         'Hosp_Affl5', 'Hosp_Affl_Lbn5',
                         'Medicare_Assgn', 'PQRS', 'EHR',
                         'MOC', 'MHI']



Phys_Comp_raw.to_csv('Physican_Compare_Cleaned.csv',sep=',', encoding='utf-8')
