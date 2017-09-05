
# coding: utf-8

# # Import Libraries

# In[1]:

import pandas as pd


# # Import dataset

# In[2]:

Providers_Optum_raw = pd.read_csv('../assets/Providers_Original.csv', low_memory = False, index_col = False)

Providers_Optum_raw.head()


# In[3]:

Providers_NAMM_raw =  pd.read_csv('../assets/NAMM_Providers_06272016.csv', low_memory = False, index_col = False)

Providers_NAMM_raw.head()


# In[4]:

Missing_raw = pd.read_csv('../assets/Optum_ENCT_Batch2_MissingNPI_20170111.csv',
                          index_col = False, low_memory = False)

Missing_raw.head()


# In[5]:

Providers_Applecare = pd.read_csv('../assets/Applecare_Providers2.csv', 
                            index_col = False, low_memory = False)

Providers_Applecare.head()


# In[6]:

Providers_Monarch_raw = pd.read_csv('../assets/SF_PROVIDER_Monarch_ACO.csv', 
                            index_col = False, low_memory = False)

Providers_Monarch_raw.head()


# In[32]:

Providers_CMS_raw = pd.read_csv('../assets/Providers_CMS_20170111.csv', 
                            index_col = False, low_memory = False)

Providers_CMS_raw.head()


# In[ ]:




# # Extract only relevant columns and rename columns for analysis

# For Provider_Optum, Providers_Monarch, Providers_NAMM, Providers_Applecare

# In[7]:

Providers_Optum = Providers_Optum_raw[['ID', 'CDO_Name',
                          'NPI', 'FirstName',
                          'LastName', 'TID']]

Providers_Optum = Providers_Optum.rename(columns = {'FirstName':'Provider_First_Name',
                                        'LastName': 'Provider_Last_Name'})

Providers_Optum.head()


# In[36]:

Providers_CMS = Providers_CMS_raw[['NPI','Last_Name','First_Name']]

Providers_CMS = Providers_CMS.rename(columns = {'First_Name':'Provider_First_Name',
                                        'Last_Name': 'Provider_Last_Name'})

Providers_CMS.head()


# In[8]:

Providers_NAMM = Providers_NAMM_raw[['NPI',
                                      'ProviderFirstName','ProviderLastName',
                                      'TaxpayerId','CDO_Name']]

Providers_NAMM = Providers_NAMM.rename(columns = {'ProviderFirstName':'Provider_First_Name',
                                        'ProviderLastName': 'Provider_Last_Name'})

Providers_NAMM.head()


# In[9]:

Providers_Monarch = Providers_Monarch_raw[['NPI',
                                      'First Name','Last Name','CDO_Name']]

Providers_Monarch = Providers_Monarch.rename(columns = {'First Name':'Provider_First_Name',
                                        'Last Name': 'Provider_Last_Name'})

Providers_Monarch.head()


# In[10]:

Providers_Applecare = Providers_Applecare.rename(columns = {'FIRST_NAME':'Provider_First_Name',
                                        'LAST_NAME': 'Provider_Last_Name'})

Providers_Applecare.head()


# In[11]:

Missing = Missing_raw

Missing = Missing.rename(columns = {'ProviderFirstName':'Provider_First_Name',
                                    'ProviderLastName': 'Provider_Last_Name'})

Missing.head()


# # Function to clean and concat Provider First Name and Last Name

# In[12]:

def name_clean(inbound):
    name = inbound.strip()
    name_split = name.split(' ')
    word_len = 0
    longest = ''
    for n in name_split:
        if len(n) > word_len:
            word_len = len(n)
            longest = n
    return longest.upper()


# In[13]:

def make_ID(row):
    last_name = name_clean(str(row['Provider_Last_Name']))
    first_name = name_clean(str(row['Provider_First_Name']))
    name = last_name + first_name
    return name


# In[14]:

def uppercase(row):
    upper = (str(row['CDO_Name'])).upper()
    return upper


# In[15]:

def make_ID_reverse(row):
    last_name = name_clean(str(row['Provider_First_Name']))
    first_name = name_clean(str(row['Provider_Last_Name']))
    name_reverse = last_name + first_name
    return name_reverse


# # Create UniquieID for Providers in all tables

# In[16]:

Providers_Optum['CDO_Name_Upper'] = Providers_Optum.apply(uppercase,axis=1)


# In[17]:

Missing['Provider_Name'] = Missing.apply(make_ID, axis = 1)


# In[18]:

Missing['Provider_Name_Reverse'] = Missing.apply(make_ID_reverse, axis = 1)


# In[20]:

Providers_NAMM['Provider_Name'] = Providers_NAMM.apply(make_ID, axis = 1)


# In[21]:

Providers_Applecare['Provider_Name'] = Providers_Applecare.apply(make_ID, axis = 1)


# In[22]:

Providers_Monarch['Provider_Name'] = Providers_Monarch.apply(make_ID, axis = 1)


# In[23]:

Providers_Optum['Provider_Name'] = Providers_Optum.apply(make_ID, axis = 1)


# In[37]:

Providers_CMS['Provider_Name'] = Providers_CMS.apply(make_ID, axis = 1)


# In[ ]:




# # Merging dataset with Optum's Provider Table to find missing value

# In[24]:

NPI_Find_NAMM = pd.merge(left = Missing, right = Providers_NAMM, 
                         on = ['Provider_Name','CDO_Name'], how = 'left')

NPI_Find_NAMM = NPI_Find_NAMM.dropna(subset = ['NPI'])

NPI_Find_NAMM.to_csv('NPI_Find_NAMM.csv', sep=',', encoding='utf-8')


# In[25]:

NPI_Find_NAMM_reverse = pd.merge(left = Missing, right = Providers_NAMM, 
                         left_on = ['Provider_Name_Reverse','CDO_Name'], 
                         right_on =['Provider_Name','CDO_Name'],
                         how = 'left')

NPI_Find_NAMM_reverse = NPI_Find_NAMM_reverse.dropna(subset = ['NPI'])

NPI_Find_NAMM_reverse.to_csv('NPI_Find_NAMM_reverse.csv', sep=',', encoding='utf-8')


# In[26]:

NPI_Find_Monarch = pd.merge(left = Missing, right = Providers_Monarch, 
                            left_on = ['Provider_Name','CDO_Name'],
                            right_on = ['Provider_Name','CDO_Name'],
                            how = 'left')

NPI_Find_Monarch = NPI_Find_Monarch.dropna(subset = ['NPI'])

NPI_Find_Monarch.to_csv('NPI_Find_Monarch.csv', sep=',', encoding='utf-8')


# In[27]:

NPI_Find_Monarch_reverse = pd.merge(left = Missing, right = Providers_Monarch, 
                         left_on = ['Provider_Name_Reverse','CDO_Name'], 
                         right_on =['Provider_Name','CDO_Name'],
                         how = 'left')

NPI_Find_Monarch_reverse = NPI_Find_Monarch_reverse.dropna(subset = ['NPI'])

NPI_Find_Monarch_reverse.to_csv('NPI_Find_Monarch_reverse.csv', sep=',', encoding='utf-8')


# In[28]:

NPI_Find_Applecare = pd.merge(left = Missing, right = Providers_Applecare,
                              left_on = ['Provider_Name','CDO_Name'], 
                              right_on =['Provider_Name','CDO_Name'],
                              how = 'left')

NPI_Find_Applecare = NPI_Find_Applecare.dropna(subset = ['NPI'])

NPI_Find_Applecare.to_csv('NPI_Find_Applecare.csv', sep=',', encoding='utf-8')


# In[29]:

NPI_Find_Applecare_reverse = pd.merge(left = Missing, right = Providers_Applecare,
                              left_on = ['Provider_Name_Reverse','CDO_Name'], 
                              right_on =['Provider_Name','CDO_Name'],
                              how = 'left')

NPI_Find_Applecare_reverse = NPI_Find_Applecare_reverse.dropna(subset = ['NPI'])

NPI_Find_Applecare_reverse.to_csv('NPI_Find_Applecare_reverse.csv', sep=',', encoding='utf-8')


# In[30]:

NPI_Find_Optum = pd.merge(left = Missing, right = Providers_Optum, 
                          left_on = ['Provider_Name','CDO_Name'], 
                          right_on =['Provider_Name','CDO_Name_Upper'],
                          how = 'left')

NPI_Find_Optum = NPI_Find_Optum.dropna(subset = ['NPI'])

NPI_Find_Optum.to_csv('NPI_Find_Optum.csv', sep=',', encoding='utf-8')


# In[31]:

NPI_Find_Optum_reverse = pd.merge(left = Missing, right = Providers_Optum, 
                          left_on = ['Provider_Name_Reverse','CDO_Name'], 
                          right_on =['Provider_Name','CDO_Name_Upper'],
                          how = 'left')

NPI_Find_Optum_reverse = NPI_Find_Optum_reverse.dropna(subset = ['NPI'])

NPI_Find_Optum_reverse.to_csv('NPI_Find_Optum_reverse.csv', sep=',', encoding='utf-8')


# # Merging dataset with CMS Provider Table to find missing NPI
# 
# CMS Provider data does not contain Tax ID

# In[38]:

NPI_Find_CMS = pd.merge(left = Missing, right = Providers_CMS, 
                          left_on = 'Provider_Name', 
                          right_on ='Provider_Name',
                          how = 'left')

NPI_Find_CMS = NPI_Find_CMS.dropna(subset = ['NPI'])

NPI_Find_CMS.to_csv('NPI_Find_CMS.csv', sep=',', encoding='utf-8')


# In[39]:

NPI_Find_CMS_reverse = pd.merge(left = Missing, right = Providers_CMS, 
                          left_on = 'Provider_Name_Reverse', 
                          right_on ='Provider_Name',
                          how = 'left')

NPI_Find_CMS_reverse = NPI_Find_CMS_reverse.dropna(subset = ['NPI'])

NPI_Find_CMS_reverse.to_csv('NPI_Find_CMS_reverse.csv', sep=',', encoding='utf-8')


# In[ ]:




# In[ ]:




# In[ ]:




# In[ ]:




# # SANDBOX

# In[ ]:

def name_clean(inbound):
    name = inbound.strip()
    name_split = name.split(' ')
    word_len = 0
    longest = ''
    for n in name_split:
        if len(n) > word_len:
            word_len = len(n)
            longest = n
    return longest.upper()

name = 'Pa Do tan'
print(name_clean(name))


# In[ ]:

def make_id(str1, str2):
    last_name = name_clean(str1)
    first_name = name_clean(str2)
    name = last_name + first_name
    return name

str1 = 'Phat Tan'
str2 = 'Dr Doan'

name = make_id(str2,str1)
print(name)


# # Archive Code

# In[ ]:

headers_missing =['Inbound_ASM_Id',
      'File_LINE_NUM',
      'DTL',
      'TPID',
      'REFERENCE_NUMBER',
      'Emerald_Barcode_ID',
      'PLAN_MEMBER_ID',
      'MEMBER_SSN',
      'Member_Last_Name',
      'Member_Middle_Initial',
      'Member_First_Name',
      'MEMBER_DATE_OF_BIRTH',
      'Member_Gender_Code',
      'MEMBER_MEDICARE_STATE_CODE',
      'HICN',
      'Claim_Date_of_Service_From',
      'Claim_Date_of_Service_Thru',
      'Bill_Type',
      'Discharge_Status',
      'Provider_ID',
      'Provider_NPIN',
      'Provider_Type',
      'Facility_Name',
      'Provider_Last_Name',
      'Provider_First_Name',
      'CMS_SPECIALTY_TYPE',
      'Provider_Federal_Tax_ID',
      'Provider_Group_Name',
      'Provider_Group_NPI',
      'CPT_Code',
      'Revenue_Code',
      'SERVICE_DETAIL_DOS_FROM',
      'SERVICE_DETAIL_DOS_THRU',
      'POS',
      'ICD_Indicator',
      'RISK_ASSESSMENT_CODE',
      'Chart_Type',
      'CHART_BARCODE',
      'CHART_ENCOUNTER_KEY',
      'Health_Plan_Name',
      'CHART_DX_Key',
      'Group_Name',
      'Contract_ID',
      'MemberAddress1',
      'MemberAddress2',
      'MemberCity',
      'MemberState',
      'MemberZIP',
      'Filler_6',
      'DIAG_CODE_1',
      'DIAG_CODE_2',
      'DIAG_CODE_3',
      'DIAG_CODE_4',
      'DIAG_CODE_5',
      'DIAG_CODE_6',
      'DIAG_CODE_7',
      'DIAG_CODE_8',
      'DIAG_CODE_9',
      'DIAG_CODE_10',
      'DIAG_CODE_11',
      'DIAG_CODE_12',
      'DIAG_CODE_13',
      'DIAG_CODE_14',
      'DIAG_CODE_15',
      'DIAG_CODE_16',
      'DIAG_CODE_17',
      'DIAG_CODE_18',
      'DIAG_CODE_19',
      'DIAG_CODE_20',
      'DIAG_CODE_21',
      'DIAG_CODE_22',
      'DIAG_CODE_23',
      'DIAG_CODE_24',
      'DIAG_CODE_25',
      'DIAG_CODE_26',
      'DIAG_CODE_27',
      'DIAG_CODE_28',
      'DIAG_CODE_29',
      'DIAG_CODE_30',
      'DIAG_CODE_31',
      'DIAG_CODE_32',
      'DIAG_CODE_33',
      'DIAG_CODE_34',
      'DIAG_CODE_35',
      'DIAG_CODE_36',
      'DIAG_CODE_37',
      'DIAG_CODE_38',
      'DIAG_CODE_39',
      'DIAG_CODE_40',
      'Reference_Number_Resub',
      'Error_Codes',
      'FileName',
      'ImportTimeStamp',
      'LCDO_Name',
      'Submission_Status_Flag',
      'Source',
      'Project',
      'Incremental_Status',
      'Priority',
      'Source_File_Name',
      'Status',
      'Status_Description',
      'Created_Date',
      'ProviderSpecialtyCode',
      'HCC',
      'Corrected_Provider_NPIN',
      'Corrected_Provider_NPIN_Description',
      'Corrected_Provider_Federal_Tax_ID',
      'Corrected_Provider_Federal_Tax_ID_Description',
      'Epi_Encounter_No', 'Cus_Provider_Name', ' Cus_Provider_Name_Reverse']


# In[ ]:

# Missing_raw.to_csv('Missing_raw.csv',  sep=',', encoding='utf-8')


# In[ ]:

Providers_CMS = pd.read_csv('../assets/Providers_CMS_12252016.csv', index_col = False, low_memory = False)


# In[ ]:

Providers_CMS = Providers_CMS.rename(columns = {'First_Name':'Provider_First_Name',
                                        'Last_Name': 'Provider_Last_Name'})

Providers_CMS.head()


# In[ ]:

Providers_MCC_raw = pd.read_csv('../assets/MCC_Providers_Lookup.csv', index_col = False, low_memory = False)

Providers_MCC_raw.head()


# In[ ]:




# In[ ]:



