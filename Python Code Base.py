#http://blog.yhat.com/posts/logistic-regression-and-python.html - UCLA problemset
#import library
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

#Display Math equation
from IPython.display port display, Math, Latex
display(Math(r'\sqrt{a^2 + b^2}')) 


#import dataset
df_raw = pd.read_csv("../assets/....csv")
df = df_raw.dropna() 
print df.head()

----------------------------------------------------------------------------------------------------------------
### DATAFRAME MANIPULATION

# Convert NA to 0
df = df.fillna(0)

# Group by admit - Descriptive statistics
drop_prestige = df.drop('prestige',1)
groupby_admit = drop_prestige.groupby('admit')

# rename columns
prestige_dummy = prestige_dummy.rename(index = str, columns ={'prestige_1.0': 'prestige_1'})

# Change data type to date
data['Date'] = pd.to_datetime(data['Date'])
data.set_index('Date', inplace=True)

# Filter by row
Segment_AAA = Delivered_raw[(Delivered_raw.Segment == 'AAA')]

# Insert Column names before import dataframe
headers = ['Segment', 'Emerald','Barcode','Work Item',
                               'Status','Reason','From DOS','Thru DOS',
                              'Service Type','Page']


# Exact Columns
Segment_BBB = Segment_BBB_raw[['Segment', 'Emerald','Barcode','Work Item',
                               'Status','Reason','From DOS','Thru DOS',
                              'Service Type','Page']]

----------------------------------------------------------------------------------------------------------------
####################
BASIC STATISCTICS
####################
df.statistics()
df.mean()
df.max()
df.min()
df.mode()
df.shape()

----------------------------------------------------------------------------------------------------------------    
# Fuzzy match
# There is a module in the standard library (called difflib) that can compare strings 
# and return a score based on their similarity. The SequenceMatcher class should do what you are after.

from difflib import SequenceMatcher as SM
s1 = ' It was a dark and stormy night. I was all alone sitting on a red chair. I was not completely alone as I had three cats.'
s2 = ' It was a murky and stormy night. I was all alone sitting on a crimson chair. I was not completely alone as I had three felines.'
SM(None, s1, s2).ratio()

----------------------------------------------------------------------------------------------------------------
# Summary table for the dataset
df.describe()

# frequency table for prestige and whether or not someone was admitted
prestige = pd.crosstab(index = df["prestige"],columns = "count")
print prestige
plt.hist(df["prestige"])

#Odds ratio
params = result.params
conf = result.conf_int()
conf['OR'] = params
conf.columns = ['2.5%', '97.5%', 'OR']
print np.exp(conf)

----------------------------------------------------------------------------------------------------------------
#New column with one codition
df['Current_HCC_Captured_Comparision'] = np.where(df['Current_HCC_Captured_F71']>df['Current_HCC_Captured_72'],'True','False')
df['Current_HCC_Captured_Comparision'].head()

#New column with with multiple coditions
# data dictionary
# 0: cannot happen, need to check for error
# 1: episource captured additional value through chart audit
# 2: there are additional value from claims that episource did not capture
# 3: aditional value from both claims and chart audit
def captured_compare(row):
    claims = row['Current_HCC_Captured_F71']
    audit = row['Current_HCC_Captured_72']
    combo = row['Current_HCC_Captured_74']
    larger = max(claims, audit)
    if combo < larger:
        return(0)
    else: 
        if (claims + audit) == combo:
            return(1)
        elif larger == combo:
            if larger == claims:
                return(2)
            elif larger == audit:
                return(1)
        else:
            return(3)   

df['Current_HCC_Captured_Comparision'] = df.apply(captured_compare, axis=1)
df['Current_HCC_Captured_Comparision'].head()

----------------------------------------------------------------------------------------------------------------
# Clean string and exact to create unique member ID
http://www.pythonforbeginners.com/basics/string-manipulation-in-python

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

# Replace
def dx_string(number):
    number = str(number)
    number = number.replace('.','')
    return number

# Merging dataset
#merging weekly Us Income varibale with the exploratory dataset
explore = pd.merge(left = explore , right = weekly_income, left_on = 'Year2', right_on = 'Year2', how= 'inner')

# Merging with multiple conditions
s1 = pd.merge(df1, df2, how='left', on=['Year', 'Week', 'Colour'])

# Formatting Date
df['Received Date Temp'] = pd.to_datetime(df['Received Date'])
df.set_index('Received Date', inplace=True)
df['Delivered Date Temp'] = pd.to_datetime(df['Delivered Date'])

# Get weekdate
def get_weekday (row):
    the_date = row['Received Date Temp']
    return the_date.weekday()
    
df['Received Weekday'] = df.apply(get_weekday, axis=1)

----------------------------------------------------------------------------------------------------------------
########################
VISUAL GRAPHICS
########################

#heatmap
cmap = sns.diverging_palette(220, 10, as_cmap=True)
correlations = data[['admit','gre','gpa','prestige_2.0','prestige_3.0','prestige_4.0']].corr()
print correlations
print sns.heatmap(correlations, cmap=cmap)

#sorting the NHE correlation relationships
corr_nhe_yoy = correlations_nhe_explore_yoy['NHE']
corr_nhe_yoy.head()
corr_nhe_yoy.sort_values( ascending =0)

# basic plot
plt.boxplot(df)

# notched plot
plt.figure()
plt.boxplot(df, 1)

#scatter plot with 3 plots on 1 Y axis
fig, axs = plt.subplots(1, 3, sharey=True)
df.plot(kind='scatter', x='gre', y='admit', ax=axs[0], figsize=(16, 8))
df.plot(kind='scatter', x='gpa', y='admit', ax=axs[1])
df.plot(kind='scatter', x='prestige', y='admit', ax=axs[2])

# Histogram of the Prestige
plt.hist(df["prestige"])
blue_patch = mpatches.Patch(color='blue', label='Count of Prestige')
plt.legend(handles=[blue_patch])

df.hist('prestige', by = 'admit')

#GRE vs. GPA scatterplot with admit as color using Seaborn
sns.set_context("notebook", font_scale=1.5)
sns.set_style("ticks")

sns.lmplot('gre', 'gpa', 
           data=df, 
           fit_reg=False, 
           #dropna=True,
           hue="admit",  
           col = "prestige",
           #scatter_kws={"marker": "D", "s": 100}
           palette = "Set1")


# instead of generating all possible values of GRE and GPA, we're going
# to use an evenly spaced range of 10 values from the min to the max
gres = np.linspace(data['gre'].min(), data['gre'].max(), 10)
print gres

gpas = np.linspace(data['gpa'].min(), data['gpa'].max(), 10)
print gpas


# looping with 10x10 subplot
plt.figure(0)

i = 0
j = 0
for i in range(0,9):
    for j in range(0,9):
        plt.subplot2grid((10,10), (i,j)), plt.imshow(X[i+j].reshape(28,28),cmap='Greys')
        j += j
    i += i
    
plt.show()

----------------------------------------------------------------------------------------------------------------
###########################  
PROBABILITY PREDICTION
###########################

#define the cartesian function
def cartesian(arrays, out=None):
    arrays = [np.asarray(x) for x in arrays]
    dtype = arrays[0].dtype

    n = np.prod([x.size for x in arrays])
    if out is None:
        out = np.zeros([n, len(arrays)], dtype=dtype)

    m = n / arrays[0].size
    out[:,0] = np.repeat(arrays[0], m)
    if arrays[1:]:
        cartesian(arrays[1:], out=out[0:m,1:])
        for j in xrange(1, arrays[0].size):
            out[j*m:(j+1)*m,1:] = out[0:m,1:]
    return out

# enumerate all possibilities
combos = pd.DataFrame(cartesian([gres, gpas, [1, 2, 3, 4], [1.]]))
# recreate the dummy variables
combos.columns = ['gre', 'gpa', 'prestige', 'intercept']
dummy_ranks = pd.get_dummies(combos['prestige'], prefix='prestige')
dummy_ranks.columns = ['prestige_1', 'prestige_2', 'prestige_3', 'prestige_4']

# keep only what we need for making predictions
cols_to_keep = ['gre', 'gpa', 'prestige', 'intercept']
combos = combos[cols_to_keep].join(dummy_ranks.ix[:, 'prestige_1':])

# make predictions on the enumerated dataset
combos['admit_pred'] = result.predict(combos[train_cols])

print combos.head()


def isolate_and_plot(variable):
    # isolate gre and class rank
    grouped = pd.pivot_table(combos, values=['admit_pred'], index=[variable, 'prestige'],
                            aggfunc=np.mean)
    
    # in case you're curious as to what this looks like
    # print grouped.head()
    #                      admit_pred
    # gre        prestige            
    # 220.000000 1           0.282462
    #            2           0.169987
    #            3           0.096544
    #            4           0.079859
    # 284.444444 1           0.311718
    
    # make a plot
    colors = 'rbgyrbgy'
    for col in combos.prestige.unique():
        plt_data = grouped.ix[grouped.index.get_level_values(1)==col]
        pl.plot(plt_data.index.get_level_values(0), plt_data['admit_pred'],
                color=colors[int(col)])

    pl.xlabel(variable)
    pl.ylabel("P(admit=1)")
    pl.legend(['1', '2', '3', '4'], loc='upper left', title='Prestige')
    pl.title("Prob(admit=1) isolating " + variable + " and presitge")
    pl.show()

isolate_and_plot('gre')
isolate_and_plot('gpa')


Claims_RAF_Projected = df['Current_RAF_Projected_F71'].mean()
print Claims_RAF_Projected

Combine_RAF_Projected = df['Current_RAF_Projected_74'].mean()
print Combine_RAF_Projected

y = [Claims_RAF_Projected, Combine_RAF_Projected]
N = len(y)
x = range(N)
width = 1/1.5
name = ['Pre-Audit', 'Post-Audit']
y_pos = np.arange(len(name))

plt.bar(x,y, width, color = "blue")
plt.xticks(y_pos, name)
plt.ylabel('RAF Projected')
plt.title('RAF Projected')


# 2 axis longitude plot
fig, ax1 = plt.subplots()
ax1.plot(year_nhe['Year2'],year_nhe['NHE'],'b-')
ax1.set_xlabel('Year')
ax1.set_ylabel('National Health Expenditure ($Million)', color = 'b')
for tl in ax1.get_yticklabels():
    tl.set_color('b')
    
ax2 = ax1.twinx()
ax2.plot(year_nhe['Year2'],year_nhe['NHE_YoY'],'r')
ax2.set_xlabel('Year')
ax2.set_ylabel('Year-over-Year Percentage Changes (%)', color = 'r')
for tl in ax2.get_yticklabels():
    tl.set_color('r')
plt.show()

----------------------------------------------------------------------------------------------------------------
##########################
REGRESSION
##########################

# this is the standard import if you're using "formula notation" (similar to R)
import statsmodels.formula.api as smf

# create a fitted model in one line
#formula notiation is the equivalent to writting out our models such that 'outcome = predictor'
#with the follwing syntax formula = 'outcome ~ predictor1 + predictor2 ... predictorN'
lm = smf.ols(formula='Sales ~ TV', data=data).fit()

#print the full summary
lm.summary()

# log regress w/ sklearn
import statsmodels.formula.api as smf
from sklearn import feature_selection, linear_model

""""
def get_linear_model_metrics(X, y, algo):
    # get the pvalue of X given y. Ignore f-stat for now.
    pvals = feature_selection.f_regression(X, y)[1]
    # start with an empty linear regression object
    # .fit() runs the linear regression function on X and y
    algo.fit(X,y)
    residuals = (y-algo.predict(X)).values

    # print the necessary values
    print 'P Values:', pvals
    print 'Coefficients:', algo.coef_
    print 'y-intercept:', algo.intercept_
    print 'R-Squared:', algo.score(X,y)
    plt.figure()
    plt.hist(residuals, bins=np.ceil(np.sqrt(len(y))))
    # keep the model
    return algo

y = data[['admit']]
X = data[['gre','prestige_2.0','prestige_3.0','prestige_4.0']]

lm = linear_model.LinearRegression()
get_linear_model_metrics(X, y, lm)
"""

log_y = np.log10(y+1)
print log_y.head()

lm = smf.ols(formula= ' log_y ~ gpa + gre', data=data).fit()
lm.summary()

# Decision Tree http://scikit-learn.org/stable/modules/tree.html

----------------------------------------------------------------------------------------------------------------
##########################
EXPORTING DATA
########################## 
hcc_top20_corr.to_csv('hcc_top20_corr.csv', sep=',', encoding='utf-8')


# USEFUL SNIPPETS
# List unique values in a DataFrame column
pd.unique(df.column_name.ravel())

# Convert Series datatype to numeric, getting rid of any non-numeric values
df['col'] = df['col'].astype(str).convert_objects(convert_numeric=True)

# Grab DataFrame rows where column has certain values
valuelist = ['value1', 'value2', 'value3']
df = df[df.column.isin(valuelist)]

# Grab DataFrame rows where column doesn't have certain values
valuelist = ['value1', 'value2', 'value3']
df = df[~df.column.isin(value_list)]

# Delete column from DataFrame
del df['column']

# Select from DataFrame using criteria from multiple columns
# (use `|` instead of `&` to do an OR)
newdf = df[(df['column_one']>2004) & (df['column_two']==9)]

# Rename several DataFrame columns
df = df.rename(columns = {
    'col1 old name':'col1 new name',
    'col2 old name':'col2 new name',
    'col3 old name':'col3 new name',
})

# Lower-case all DataFrame column names
df.columns = map(str.lower, df.columns)

# Even more fancy DataFrame column re-naming
# lower-case all DataFrame column names (for example)
df.rename(columns=lambda x: x.split('.')[-1], inplace=True)

# Loop through rows in a DataFrame
# (if you must)
for index, row in df.iterrows():
    print index, row['some column']  

# Next few examples show how to work with text data in Pandas.
# Full list of .str functions: http://pandas.pydata.org/pandas-docs/stable/text.html

# Slice values in a DataFrame column (aka Series)
df.column.str[0:2]

# Lower-case everything in a DataFrame column
df.column_name = df.column_name.str.lower()

# Get length of data in a DataFrame column
df.column_name.str.len()

# Sort dataframe by multiple columns
df = df.sort(['col1','col2','col3'],ascending=[1,1,0])

# Get top n for each group of columns in a sorted dataframe
# (make sure dataframe is sorted first)
top5 = df.groupby(['groupingcol1', 'groupingcol2']).head(5)

# Grab DataFrame rows where specific column is null/notnull
newdf = df[df['column'].isnull()]

# Select from DataFrame using multiple keys of a hierarchical index
df.xs(('index level 1 value','index level 2 value'), level=('level 1','level 2'))

# Change all NaNs to None (useful before
# loading to a db)
df = df.where((pd.notnull(df)), None)

# Get quick count of rows in a DataFrame
len(df.index)

# Pivot data (with flexibility about what what
# becomes a column and what stays a row).
# Syntax works on Pandas >= .14
pd.pivot_table(
  df,values='cell_value',
  index=['col1', 'col2', 'col3'], #these stay as columns; will fail silently if any of these cols have null values
  columns=['col4']) #data values in this column become their own column

# Change data type of DataFrame column
df.column_name = df.column_name.astype(np.int64)

# Get rid of non-numeric values throughout a DataFrame:
for col in refunds.columns.values:
  refunds[col] = refunds[col].replace('[^0-9]+.-', '', regex=True)

# Set DataFrame column values based on other column values (h/t: @mlevkov)
df.loc[(df['column1'] == some_value) & (df['column2'] == some_other_value), ['column_to_change']] = new_value

# Clean up missing values in multiple DataFrame columns
df = df.fillna({
    'col1': 'missing',
    'col2': '99.999',
    'col3': '999',
    'col4': 'missing',
    'col5': 'missing',
    'col6': '99'
})

# Concatenate two DataFrame columns into a new, single column
# (useful when dealing with composite keys, for example)
df['newcol'] = df['col1'].map(str) + df['col2'].map(str)

# Doing calculations with DataFrame columns that have missing values
# In example below, swap in 0 for df['col1'] cells that contain null
df['new_col'] = np.where(pd.isnull(df['col1']),0,df['col1']) + df['col2']

# Split delimited values in a DataFrame column into two new columns
df['new_col1'], df['new_col2'] = zip(*df['original_col'].apply(lambda x: x.split(': ', 1)))

# Collapse hierarchical column indexes
df.columns = df.columns.get_level_values(0)

# Convert Django queryset to DataFrame
qs = DjangoModelName.objects.all()
q = qs.values()
df = pd.DataFrame.from_records(q)

# Create a DataFrame from a Python dictionary
df = pd.DataFrame(list(a_dictionary.items()), columns = ['column1', 'column2'])

# Get a report of all duplicate records in a dataframe, based on specific columns
dupes = df[df.duplicated(['col1', 'col2', 'col3'], keep=False)]

# Set up formatting so larger numbers aren't displayed in scientific notation (h/t @thecapacity)
pd.set_option('display.float_format', lambda x: '%.3f' % x)

# Compare a data frame against a standard guideline
def find_group(trumped_code,suspect_code):
    test = False
    for i in range(0, len(Trump_Ref.index)):
        if trumped_code == str(Trump_Ref.get_value(i,'TRUMPED_CODE')):
            if suspect_code == str(Trump_Ref.get_value(i,'HCC_CODE')):
                test = True
                break
    return test
            
trumped_code = '12'
suspect_code = '10'

test = find_group(trumped_code, suspect_code)

print(test)


----------------------------------------------------------------------------------------------------------------
##########################
JSON query
##########################

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
        npi= str(data["results"][0]['basics'][0]['name'])
        name = data["results"][0]["basic"]
        list_temp = [index, name, npi]
    except:
        count = 0
        npi= 0
    
    if count == 1:
        index = index + 1
        output_data.loc[len(output_data)] = list_temp

----------------------------------------------------------------------------------------------------------------
##########################
Statistical Analysis
##########################
==============
ANOVA
==============
# compute one-way ANOVA P value   
from scipy import stats  
      
f_val, p_val = stats.f_oneway(treatment1, treatment2, treatment3)  
  
print "One-way ANOVA P =", p_val  
  
One-way ANOVA P = 0.381509481874  


==============
Confidence Interval
==============
# compute 95% confidence intervals around the mean  
CIs = bootstrap.ci(data=A_totalAdd, statfunction=scipy.mean)  
  
print("Bootstrapped 95% confidence intervals\nLow:", CIs[0], "\nHigh:", CIs[1])


==============
t-test
==============
stats.ttest_ind(rvs1,rvs2)

----------------------------------------------------------------------------------------------------------------
==============
3D scatterplot
==============

#Demonstration of a basic scatterplot in 3D.

from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt
import numpy as np


def randrange(n, vmin, vmax):
    '''
    Helper function to make an array of random numbers having shape (n, )
    with each number distributed Uniform(vmin, vmax).
    '''
    return (vmax - vmin)*np.random.rand(n) + vmin

fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')

n = 100

# For each set of style and range settings, plot n random points in the box
# defined by x in [23, 32], y in [0, 100], z in [zlow, zhigh].
for c, m, zlow, zhigh in [('r', 'o', -50, -25), ('b', '^', -30, -5)]:
    xs = randrange(n, 23, 32)
    ys = randrange(n, 0, 100)
    zs = randrange(n, zlow, zhigh)
    ax.scatter(xs, ys, zs, c=c, marker=m)

ax.set_xlabel('X Label')
ax.set_ylabel('Y Label')
ax.set_zlabel('Z Label')

plt.show()
