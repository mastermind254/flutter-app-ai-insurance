import pandas as pd
import numpy as np
import seaborn as sns
import datetime
import matplotlib.pyplot as plt
import plotly.express as px
from plotly.subplots import make_subplots
import plotly.graph_objects as go

#Reading the file
df = pd.read_csv("/fraud_oracle.csv")

df.head()
# Output
"""
    Month	WeekOfMonth	DayOfWeek	Make	AccidentArea	DayOfWeekClaimed	MonthClaimed	WeekOfMonthClaimed	Sex	MaritalStatus	...	WitnessPresent	AgentType	NumberOfSuppliments	AddressChange_Claim	NumberOfCars	Year	BasePolicy	Unnamed: 33	Unnamed: 34	Statement
0	Dec	5	Wednesday	Honda	Urban	Tuesday	Jan	1	Female	Single	...	No	External	none	1 year	3 to 4	1994	Liability	-	Sport - Liability	True
1	Jan	3	Wednesday	Honda	Urban	Monday	Jan	4	Male	Single	...	No	External	none	no change	1 vehicle	1994	Collision	-	Sport - Collision	True
2	Oct	5	Friday	Honda	Urban	Thursday	Nov	2	Male	Married	...	No	External	none	no change	1 vehicle	1994	Collision	-	Sport - Collision	True
3	Jun	2	Saturday	Toyota	Rural	Friday	Jul	1	Male	Married	...	No	External	more than 5	no change	1 vehicle	1994	Liability	-	Sport - Liability	False
4	Jan	5	Monday	Honda	Urban	Tuesday	Feb	2	Female	Single	...	No	External	none	no change	1 vehicle	1994	Collision	-	Sport - Collision	True
5 rows × 36 columns
"""