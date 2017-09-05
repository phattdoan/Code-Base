### IMPORT DATASET as df
%matplotlib inline
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import pandas as pd
import statsmodels.api as sm
import pylab as pl
import numpy as np

#import seaborn 
import seaborn as sns
sns.set_style("darkgrid")
import sklearn.linear_model

#import SMC AHA Coding Results
AHA = pd.read_csv("../assets/dataset/SMC_AHA_Coding_Results_10212016_12092016.csv")

#import SMC Pilot (Chart Audit) Coding Results
Pilot = pd.read_csv("../assets/dataset/SMC_Pilot_Coding_Results.csv")

#import consolidate SMC 250 members that have claims and chart audit with results from epiA
RAF250 = pd.read_csv("../assets/dataset/SMC_250Members_RAF_Results.csv")

#import DX HCC 
Dx_HCC_raw = pd.read_csv("../assets/dataset/Dx_HCC_Mapping.csv")
Dx_HCC = Dx_HCC_raw.dropna()

#import HCC_2016_Value 
HCC_Value = pd.read_csv("../assets/dataset/HCC_2016Value.csv")


# Create unique ID for each patient to comepare between different dataset
# This is due to SMC data is extremely messy, memberid for claims
# and chart audit are different
def make_ID(row):
    last_name_full = row['Member: Last Name']
    last_name_full.strip()
    last_name_split = last_name_full.split(' ')
    last_name_1st_word = str(last_name_split[0:1])
    last_name_1st_word = last_name_1st_word.strip("['']")
    
    birthday = row['Member: DOB']
    birthday.strip()

    birthday_split = birthday.split('/')

    year = str(birthday_split[2:3]).strip("['']")
    month = str(birthday_split[0:1]).strip("['']")
    day = str(birthday_split[1:2]).strip("['']")
    birthday_join = year+month+day
    
    unique_ID = last_name_1st_word + birthday_join
    return unique_ID

AHA['unique_ID'] = AHA.apply(make_ID, axis=1)
Pilot['unique_ID'] = Pilot.apply(make_ID, axis=1)
RAF250['unique_ID'] = RAF250.apply(make_ID, axis=1)

# Convert V22_Model Data type to string for Dx_HCC dataset
def hcc_string(row):
    number = row['V22_Model']
    number = str(number)
    number_round = number[:len(number)-1]
    number_round = number_round.strip('.')
    return number_round

Dx_HCC['V22_Model2'] = Dx_HCC.apply(hcc_string, axis=1)

# Cleaning V22_Model Data type to string for Dx_HCC dataset
def int_to_string(row):
    number = row['HCC_Code']
    number_str = str(number)
    return number_str

HCC_Value['HCC_Code'] = HCC_Value.apply(int_to_string, axis=1)


# Merging Dx_HCC dataset with HCC_Value dataset
Dx_HCC_Value_raw = pd.merge(left = Dx_HCC , right = HCC_Value, 
                   left_on = 'V22_Model2', right_on = 'HCC_Code', how= 'left')

# Keeping relevant columns only
Dx_HCC_Value = Dx_HCC_Value_raw[['Dx_Code','Description_y',
                                 'HCC_Code', 'Year','Value',
                                'Model']]
Dx_HCC_Value = Dx_HCC_Value.rename(columns={'Description_y':"Description"})


# Mapping Dx Codes in Pilot Chart Audit Results to HCC Value
Pilot_HCC_raw = pd.merge(left = Pilot , right = Dx_HCC_Value, 
                   left_on = 'Dx Code', right_on = 'Dx_Code', how= 'left')

# Mapping Dx Codes in Pilot Chart Audit Results to HCC Value
AHA_HCC_raw = pd.merge(left = AHA , right = Dx_HCC_Value, 
                   left_on = 'Dx Code', right_on = 'Dx_Code', how= 'left')

# Extract relevant columns
Pilot_HCC = Pilot_HCC_raw[['Member ID', 'Member: Last Name','Member: First Name', 'Member: DOB',
                      'Dx Code', 'Primary Comment','unique_ID','Description','HCC_Code',
                      'Year','Value','Model']]

AHA_HCC = AHA_HCC_raw[['Member ID', 'Member: Last Name','Member: First Name', 'Member: DOB',
                      'Dx Code', 'Primary Comment','unique_ID','Description','HCC_Code',
                      'Year','Value','Model']]

# Merging AHA and Pilot Chart Audit results, matching on unique_ID and HCC code

AHA_Pilot_HCC_raw = pd.merge(AHA_HCC, Pilot_HCC, how = 'left', on = ['unique_ID','HCC_Code'], suffixes=('_AHA', '_Pilot'))

AHA_Pilot_HCC = AHA_Pilot_HCC_raw[['Member ID_AHA','unique_ID','Member: Last Name_AHA','Member: First Name_Pilot', 'Member: DOB_AHA',
                      'Dx Code_AHA', 'HCC_Code','Value_AHA','Primary Comment_AHA','Primary Comment_Pilot','Description_AHA']]

# exact relevant columns for final analysis
AHA_Pilot_HCC = AHA_Pilot_HCC.rename(columns={"Description_AHA":"Description","Dx Code_AHA":"Dx Code","Value_AHA":"Value",
                                              "Member: Last Name_AHA":"Member: Last Name",
                                             "Member: First Name_Pilot":"Member: First Name",
                                             "Member: DOB_AHA":"Member: DOB",
                                             "Member ID_AHA":"Member ID",
                                             "unique_ID":"Unique ID",
                                             "HCC_Code":"HCC Code",
                                             "Primary Comment_AHA":"Primary Comment AHA",
                                             "Primary Comment_Pilot":"Primary Comment Pilot"})

# Compare primary comment between AHA and Pilot and where to credit to
def primary_comment_compare(row):
    aha = row['Primary Comment AHA']
    pilot = row['Primary Comment Pilot']
    result = ''
    if pilot == 'ASR':
        if aha =='':
            result = 'ASR'
        elif aha == 'ASR':
            result = 'ASR'
        elif aha =='Suspect':
            result = 'Suspect'
        elif aha == 'Add':
            result = 'Add'
        else:
            result = pilot
    elif pilot == 'Suspect':
        if aha =='':
            result = 'Suspect'
        elif aha == 'ASR':
            result = 'ASR'
        elif aha =='Suspect':
            result = 'Suspect'
        elif aha == 'Add':
            result = 'Add'
        else:
            result = pilot
    elif pilot == '':
        result = aha
    elif pilot == 'Add':
        if aha == 'Add':
            result = 'Confirm'
        else:
            result = 'Add'
    return result

AHA_Pilot_HCC['Comment_Compare'] = AHA_Pilot_HCC.apply(primary_comment_compare,axis=1)