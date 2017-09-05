
# coding: utf-8

# # Import Libraries

# In[1]:

import pandas as pd


# # Import dataset

# In[2]:

Providers_raw = pd.read_csv('../assets/Providers_Original.csv', low_memory = False, index_col = False)

Providers_raw.head()


# In[3]:

NPI_Missing_raw = pd.read_csv('../assets/EnctReview_NPI_Missing_12252016.csv', index_col = False, low_memory = False)

NPI_Missing_raw.head()


# In[4]:

FedTaxID_Missing_raw = pd.read_csv('../assets/EnctReview_FedTaxID_Missing_12252016.csv', index_col = False, low_memory = False)

FedTaxID_Missing_raw.head()


# In[36]:

Providers_CMS = pd.read_csv('../assets/Providers_CMS_12252016.csv', index_col = False, low_memory = False)


# In[40]:

Providers_CMS = Providers_CMS.rename(columns = {'First_Name':'Provider_First_Name',
                                        'Last_Name': 'Provider_Last_Name'})

Providers_CMS.head()


# In[ ]:




# # Extract only relevant columns for analysis

# In[5]:

Providers = Providers_raw[['ID', 'CDO_Name',
                          'NPI', 'OrgName', 'FirstName',
                          'LastName', 'TID', 'Taxonomy']]

Providers = Providers.rename(columns = {'FirstName':'Provider_First_Name',
                                        'LastName': 'Provider_Last_Name'})


# In[6]:

Providers.head()


# In[25]:

NPI_Missing = NPI_Missing_raw[['Inbound_ASM_Id', 'Provider_Last_Name',
                               'Provider_First_Name', 'LCDO_Name']]

NPI_Missing.head()


# In[26]:

FedTaxID_Missing = FedTaxID_Missing_raw[['Inbound_ASM_Id', 'Provider_Last_Name',
                                         'Provider_First_Name', 'LCDO_Name']]

FedTaxID_Missing.head()


# # Function to clean and concat Provider First Name and Last Name

# In[9]:

def make_ID(row):
    last_name_full = str(row['Provider_Last_Name'])
    last_name_full.strip()
    first_name_full = str(row['Provider_First_Name'])
    first_name_full.strip()
    unique_ID = last_name_full + first_name_full
    return unique_ID


# In[10]:

def make_ID_reverse(row):
    last_name_full = str(row['Provider_First_Name'])
    last_name_full.strip()
    first_name_full = str(row['Provider_Last_Name'])
    first_name_full.strip()
    unique_ID = last_name_full + first_name_full
    return unique_ID


# In[27]:

NPI_Missing['Provider_Name'] = NPI_Missing.apply(make_ID, axis = 1)


# In[28]:

NPI_Missing['Provider_Name_Reverse'] = NPI_Missing.apply(make_ID_reverse, axis = 1)


# In[29]:

FedTaxID_Missing['Provider_Name'] = FedTaxID_Missing.apply(make_ID, axis = 1)


# In[30]:

FedTaxID_Missing['Provider_Name_Reverse'] = FedTaxID_Missing.apply(make_ID_reverse, axis = 1)


# In[46]:

NPI_Missing.to_csv('NPI_Missing_12252016.csv', sep=',', encoding='utf-8')

FedTaxID_Missing.to_csv('FedTaxID_Missing_12252016.csv', sep=',', encoding='utf-8')


# In[15]:

Providers['Provider_Name'] = Providers.apply(make_ID, axis = 1)


# In[16]:

Providers.head()


# In[41]:

Providers_CMS['Provider_Name'] = Providers_CMS.apply(make_ID, axis = 1)


# In[17]:

# drop NPI without value
Providers_NPI = Providers.dropna(subset=['NPI'])


# In[18]:

# drop TID without valua
Providers_TID = Providers.dropna(subset=['TID'])


# In[19]:

Providers_NPI.head()
len(Providers_NPI)


# In[20]:

Providers_TID.head()
len(Providers_TID)


# # Merging dataset with Optum's Provider Table to find missing value

# In[31]:

NPI_Find = pd.merge(left = NPI_Missing, right = Providers_NPI, left_on = 'Provider_Name',
                    right_on = 'Provider_Name', how = 'left')

NPI_Find.to_csv('NPI_Find.csv', sep=',', encoding='utf-8')


# In[32]:

NPI_Find_Reverse = pd.merge(left = NPI_Missing, right = Providers_NPI, left_on = 'Provider_Name_Reverse',
                    right_on = 'Provider_Name', how = 'left')

NPI_Find_Reverse.to_csv('NPI_Find_Reverse.csv', sep=',', encoding='utf-8')


# In[33]:

FedTaxID_Find =  pd.merge(left = FedTaxID_Missing, right = Providers_TID, left_on = 'Provider_Name',
                    right_on = 'Provider_Name', how = 'left')

FedTaxID_Find.to_csv('FedTaxID_Find.csv', sep=',', encoding='utf-8')


# In[35]:

FedTaxID_Find_Reverse =  pd.merge(left = FedTaxID_Missing, right = Providers_TID, left_on = 'Provider_Name_Reverse',
                    right_on = 'Provider_Name', how = 'left')

FedTaxID_Find_Reverse.to_csv('FedTaxID_Find_Reverse.csv', sep=',', encoding='utf-8')


# # Merging dataset with CMS Provider Table to find missing NPI
# 
# CMS Provider data does not contain Tax ID

# In[42]:

NPI_Find_CMS = pd.merge(left = NPI_Missing, right = Providers_CMS, left_on = 'Provider_Name',
                    right_on = 'Provider_Name', how = 'left')

NPI_Find_CMS.to_csv('NPI_Find_CMS.csv', sep=',', encoding='utf-8')


# In[43]:

NPI_Find_Reverse_CMS = pd.merge(left = NPI_Missing, right = Providers_CMS, left_on = 'Provider_Name_Reverse',
                    right_on = 'Provider_Name', how = 'left')

NPI_Find_Reverse_CMS.to_csv('NPI_Find_Reverse_CMS.csv', sep=',', encoding='utf-8')


# In[ ]:




# In[ ]:




# In[ ]:




# In[ ]:



