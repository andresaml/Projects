#  Import the python libraries
from pandas_datareader import data as web
import pandas as pd
import numpy as np
from datetime import datetime
import matplotlib.pyplot as plt
plt.style.use('fivethirtyeight')

# Get th stocks symbols in the portfolio
assets = ['FB', 'AMZN', 'AAPL', 'NFLX', 'GOOG', 'MSFT', 'TSLA', 'NVDA', 'JPM', 'MRNA']

# Assign weights
weights = np.array([0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1])

# Get the portfolio starting date
stockStartDate = '2013-01-01'

# Get the ending date (today)
today = datetime.today().strftime('%Y-%m-%d')
print(today)

# Create a dataframe to store the adjusted close price of the stock
df = pd.DataFrame()

# Store the adjusted close price of the stocks into the df
for stock in assets:
    df[stock] = web.DataReader(stock, data_source='yahoo', start=stockStartDate, end=today)['Adj Close']

print(df)

# Visualize show the portfolio
title = 'Portfolio Adj. Close Price History'

# Get the stocks
my_stocks = df

# Create and plot the graph
for c in my_stocks.columns.values:
    plt.plot(my_stocks[c], label = c, linewidth = 1.5)

plt.title(title)
plt.xlabel('Date', fontsize = 18)
plt.ylabel('Adj. Price USD ($)', fontsize = 18)
plt.legend(my_stocks.columns.values, loc = 'upper left')
plt.show()

# Show the daily simple return
returns = df.pct_change()
print(returns)

# Show annualized covariance matrix
cov_matrix_annual = returns.cov() * 252
print(cov_matrix_annual)

# Calculate the portfolio variance
port_variance = np.dot(weights.T, np.dot(cov_matrix_annual, weights))
print(port_variance)

# Calculate the portfolio volatility aka standard deviation
port_volatility = np.sqrt(port_variance)
print(port_volatility)

# Calculate the annual portfolio return
portfolioSimpleAnnualReturn = np.sum(returns.mean() * weights) * 252
print(portfolioSimpleAnnualReturn)

# Show the expected annual return, volatility and the variance
percent_var = str(round(port_variance, 4) * 100) + '%'
percent_vol = str(round(port_volatility, 4) * 100) + '%'
percent_ret = str(round(portfolioSimpleAnnualReturn, 4) * 100) + '%'

print('Expected annual Return: ' + percent_ret)
print('Annual Volatility: ' + percent_vol)
print('Annual variance: ' + percent_var)

# Install PyPortfolioOpt
from pypfopt.efficient_frontier import EfficientFrontier
from pypfopt import risk_models
from pypfopt import expected_returns

# Portfolio Optimization

# Calculate the expected returns and annualised sample covariance matrix of asset return
mu = expected_returns.mean_historical_return(df)
S = risk_models.sample_cov(df)

# Optimize for max sharpe ratio
ef = EfficientFrontier(mu, S)
weights = ef.max_sharpe()
cleaned_weights = ef.clean_weights()
print(cleaned_weights)
ef.portfolio_performance(verbose = True)

# Get the discrete allocation of each share per stock
from pypfopt.discrete_allocation import DiscreteAllocation, get_latest_prices
latest_prices = get_latest_prices(df)
weights = cleaned_weights
da = DiscreteAllocation(weights, latest_prices, total_portfolio_value=30000)

allocation, leftover = da.lp_portfolio()
print('Discrete allocation:', allocation)
print('Funds remaining: ${:.2f}'.format(leftover))
