# Created by Joanna Lin and Phat Doan
# Last update: 01/16/2017

import json
import pandas as pd
import requests
#import sys

Providers= pd.read_csv('../assets/Missing_NPI_TIN_20170117.csv', 
                            index_col = False, low_memory = False)

# Make sure the input column for the provider's first and last name matched below
Providers = Providers.rename(columns = {'ProviderFirstName':'First_Name_Org',
                                        'ProviderLastName': 'Last_Name_Org'})

def last_name_clean(row):
    name = str(row['Last_Name_Org'])
    name_split = name.split(' ')
    word_len = 0
    longest = ''
    for n in name_split:
        if len(n) > word_len:
            word_len = len(n)
            longest = n
    return longest.upper()

def first_name_clean(row):
    name = str(row['First_Name_Org'])
    name_split = name.split(' ')
    word_len = 0
    longest = ''
    for n in name_split:
        if len(n) > word_len:
            word_len = len(n)
            longest = n
    return longest.upper()

Providers['Last_Name_Clean'] = Providers.apply(last_name_clean, axis = 1)

Providers['First_Name_Clean'] = Providers.apply(first_name_clean, axis = 1)

# Default state is California
Providers['State'] = 'CA'

fields = [u'index',u'name',u'npi']  

Results_Data = pd.DataFrame(columns = fields)

json_list = []

for i, row in Providers.iterrows():
    last_name = row['Last_Name_Clean']
    first_name = row['First_Name_Clean']
    state = row['State']
    url = "https://npiregistry.cms.hhs.gov/api/?first_name=" + first_name + "&last_name=" + last_name +"&state=" + state
    url_reversve = "https://npiregistry.cms.hhs.gov/api/?first_name=" + first_name + "&last_name=" + last_name +"&state=" + state
    response = requests.get(url)
    json_list.append(response.json())
    
index = 1
for data in json_list:
    try:
        count= int(data["result_count"])
        npi= str(data["results"][0]['number'])
        name = str(data["results"][0]["basic"]["name"])
        list_temp = [index, name, npi]
    except:
        count = 0
        npi= 0
        name = ""

    if count == 1:
        index = index + 1
        Results_Data.loc[len(Results_Data)] = list_temp
    
Results_Data.to_csv('Result_Data.csv', sep=',', encoding='utf-8')
