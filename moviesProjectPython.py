# %%
import pandas as pd
import seaborn as sns
import matplotlib
import matplotlib.pyplot as plt
plt.style.use('ggplot')
from matplotlib.pyplot import figure
import numpy as np

%matplotlib inline
matplotlib.rcParams['figure.figsize'] = (12,8)

# %%
#Change directory to read csv
movies = pd.read_csv('../a/movies.csv')

# %%
movies.head()

# %%
for col in movies.columns:
    pct_missing = np.mean(movies[col].isnull())
    print('{} - {}%'.format(col, pct_missing))

movies = movies.dropna()

# %%
movies.dtypes

# %%
#Change budget and gross to int
movies['budget'] = movies['budget'].astype('int64')
movies['gross'] = movies['gross'].astype('int64')

# %%
#Creating correct year column
movies['yearCorrect'] = movies['released'].str.extract(pat='([0-9]{4})').astype(int)

# %%
movies = movies.sort_values(by=['gross'],inplace=False,ascending=False)

# %%
sns.pairplot(movies)

# %% [markdown]
# ### Seaborn vs. Pyplot

# %%
plot = sns.regplot(data= movies,x='budget',y='gross', scatter_kws={'color':'red'},line_kws={'color':'blue'})
plot.set(xlabel='Budget',ylabel='Gross Revenue',title='Budget v. Gross')



# %%
plt.scatter(x=movies['budget'],y=movies['gross'])
plt.title('Budget v. Gross')
plt.xlabel('Budget')
plt.ylabel('Gross Revenue')
plt.show()

# %%
movies.corr()
'''possible correlatsions:
    score - votes
    score - runtime
    votes - budget
    votes - gross
    budget - gross'''

# %%
corrMatrix = movies.corr()

hMap = sns.heatmap(corrMatrix, annot=True)
hMap.set(xlabel='Movie Attributes', ylabel='Movie Attributes', title='Correlation of Numeric Values')

# %%
#convert data to numeric for correlation analysis
moviesConverted = movies

for col in moviesConverted.columns:
    if(moviesConverted[col].dtype == 'object'):
        moviesConverted[col] = moviesConverted[col].astype('category')
        moviesConverted[col] = moviesConverted[col].cat.codes

moviesConverted

# %%
from matplotlib.pyplot import title


corrMatrixConverted = moviesConverted.corr()
hMapConverted = sns.heatmap(corrMatrixConverted, annot=True)
hMapConverted.set(xlabel='Movie Attributes', ylabel='Movie Attributes', title='Correlation of Converted Values')

#No new correlations observed

# %%
corrMatrixUnstack = moviesConverted.corr().unstack()
corrMatrixUnstack

# %%
corrSorted = corrMatrixUnstack.sort_values()
corrSorted

# %%
highCorr = corrSorted[(corrSorted)> 0.5]
highCorr

# %%



