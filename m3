pip install pandas_ta
# Import the yfinance library
import yfinance as yf
import pandas as pd
import pandas_ta as ta
import matplotlib.pyplot as plt
# Define the SA ticker symbol
sa_ticker = "SOL.JO"
# Get the data for the SA ticker
data = yf.download(sa_ticker, start="2000-01-01", end="2023-12-31")
data.head()
# Define the risk-reward ratio
rrr = 2

# Define the exit signal function
def exit_signal(data, rrr):
  # Calculate the stop loss and take profit levels based on the entry price and the risk-reward ratio
  data['stop_loss'] = data['entry_price'] - data['atr'] * rrr
  data['take_profit'] = data['entry_price'] + data['atr'] * rrr

  # Initialize the exit signal column
  data['exit_signal'] = 0

  # Loop through the data and generate the exit signals
  for i in range(1, len(data)):
    # If the current price is lower than the stop loss or higher than the take profit, exit the position
    if data['close'][i] <= data['stop_loss'][i] or data['close'][i] >= data['take_profit'][i]:
      data['exit_signal'][i] = 1
    # Else, hold the position
    else:
      data['exit_signal'][i] = 0

  return data

  # Define the entry signals based on technical indicators
# Moving average crossover
def macd_entry(data):
  # Calculate the MACD and the signal line
  data['macd'] = ta.macd(data['close'])
  data['macd_signal'] = ta.macd(data['close'], signal=9)

  # Initialize the entry signal column
  data['macd_entry'] = 0

  # Loop through the data and generate the entry signals
  for i in range(1, len(data)):
    # If the MACD crosses above the signal line, enter a long position
    if data['macd'][i] > data['macd_signal'][i] and data['macd'][i-1] <= data['macd_signal'][i-1]:
      data['macd_entry'][i] = 1
    # If the MACD crosses below the signal line, enter a short position
    elif data['macd'][i] < data['macd_signal'][i] and data['macd'][i-1] >= data['macd_signal'][i-1]:
      data['macd_entry'][i] = -1
    # Else, do nothing
    else:
      data['macd_entry'][i] = 0

  return data


  # Bollinger Bands breakout
def bb_entry(data):
  # Calculate the Bollinger Bands
  data['bb_upper'], data['bb_middle'], data['bb_lower'] = ta.bbands(data['close'])

  # Initialize the entry signal column
  data['bb_entry'] = 0

  # Loop through the data and generate the entry signals
  for i in range(1, len(data)):
    # If the price closes above the upper band, enter a long position
    if data['close'][i] > data['bb_upper'][i] and data['close'][i-1] <= data['bb_upper'][i-1]:
      data['bb_entry'][i] = 1
    # If the price closes below the lower band, enter a short position
    elif data['close'][i] < data['bb_lower'][i] and data['close'][i-1] >= data['bb_lower'][i-1]:
      data['bb_entry'][i] = -1
    # Else, do nothing
    else:
      data['bb_entry'][i] = 0

  return data

  # RSI divergence
def rsi_entry(data):
  # Calculate the RSI
  data['rsi'] = ta.rsi(data['close'])

  # Initialize the entry signal column
  data['rsi_entry'] = 0

  # Loop through the data and generate the entry signals
  for i in range(2, len(data)):
    # If the price makes a lower low but the RSI makes a higher low, enter a long position
    if data['close'][i] < data['close'][i-1] and data['rsi'][i] > data['rsi'][i-1] and data['close'][i-1] < data['close'][i-2] and data['rsi'][i-1] < data['rsi'][i-2]:
      data['rsi_entry'][i] = 1
    # If the price makes a higher high but the RSI makes a lower high, enter a short position
    elif data['close'][i] > data['close'][i-1] and data['rsi'][i] < data['rsi'][i-1] and data['close'][i-1] > data['close'][i-2] and data['rsi'][i-1] > data['rsi'][i-2]:
      data['rsi_entry'][i] = -1
    # Else, do nothing
    else:
      data['rsi_entry'][i] = 0

  return data


  # MACD histogram
def macd_hist_entry(data):
  # Calculate the MACD histogram
  data['macd_hist'] = ta.macd(data['close'], histogram=True)

  # Initialize the entry signal column
  data['macd_hist_entry'] = 0

  # Loop through the data and generate the entry signals
  for i in range(1, len(data)):
    # If the MACD histogram changes from negative to positive, enter a long position
    if data['macd_hist'][i] > 0 and data['macd_hist'][i-1] <= 0:
      data['macd_hist_entry'][i] = 1
    # If the MACD histogram changes from positive to negative, enter a short position
    elif data['macd_hist'][i] < 0 and data['macd_hist'][i-1] >= 0:
      data['macd_hist_entry'][i] = -1
    # Else, do nothing
    else:
      data['macd_hist_entry'][i] = 0

  return data

  # Stochastic oscillator
def stoch_entry(data):
  # Calculate the stochastic oscillator
  data['stoch_k'], data['stoch_d'] = ta.stoch(data['high'], data['low'], data['close'])

  # Initialize the entry signal column
  data['stoch_entry'] = 0

  # Loop through the data and generate the entry signals
  for i in range(1, len(data)):
    # If the stochastic K crosses above the stochastic D and both are below 20, enter a long position
    if data['stoch_k'][i] > data['stoch_d'][i] and data['stoch_k'][i-1] <= data['stoch_d'][i-1] and data['stoch_k'][i] < 20 and data['stoch_d'][i] < 20:
      data['stoch_entry'][i] = 1
    # If the stochastic K crosses below the stochastic D and both are above 80, enter a short position
    elif data['stoch_k'][i] < data['stoch_d'][i] and data['stoch_k'][i-1] >= data['stoch_d'][i-1] and data['stoch_k'][i] > 80 and data['stoch_d'][i] > 80:
      data['stoch_entry'][i] = -1
    # Else, do nothing
    else:
      data['stoch_entry'][i] = 0

  return data

  # Define the trading systems based on different combinations of entry signals and market conditions
# System 1: Moving average crossover and trend signal
def system_1(data):
  # Calculate the 50-day and 200-day simple moving averages
  data['sma_50'] = ta.sma(data['close'], length=50)
  data['sma_200'] = ta.sma(data['close'], length=200)

  # Calculate the trend signal based on the slope of the 200-day moving average
  data['trend_signal'] = data['sma_200'].diff().apply(lambda x: 1 if x > 0 else -1)

  # Initialize the system signal column
  data['system_1_signal'] = 0

  # Loop through the data and generate the system signals
  for i in range(1, len(data)):
    # If the 50-day moving average crosses above the 200-day moving average and the trend signal is positive, enter a long position
    if data['sma_50'][i] > data['sma_200'][i] and data['sma_50'][i-1] <= data['sma_200'][i-1] and data['trend_signal'][i] == 1:
      data['system_1_signal'][i] = 1
    # If the 50-day moving average crosses below the 200-day moving average and the trend signal is negative, enter a short position
    elif data['sma_50'][i] < data['sma_200'][i] and data['sma_50'][i-1] >= data['sma_200'][i-1] and data['trend_signal'][i] == -1:
      data['system_1_signal'][i] = -1
    # Else, do nothing
    else:
      data['system_1_signal'][i] = 0

  # Return the data with the system signal column
  return data
