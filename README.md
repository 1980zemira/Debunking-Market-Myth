# Debunking-Market-Myth
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
# Generating a sample price data
np.random.seed(42)
price_data = np.random.rand(200) * 10 + 50
df = pd.DataFrame({'Price': price_data})


# We now define common exit signal based on risk-reward ratio

def apply_exit_strategy(data, risk_reward_ratio=2):
    print(data.columns)  # Add this line to print column names
    data['Exit_Signal'] = 0.0

    for index, row in data.iterrows():
        if 'Position' in data.columns and row['Position'] == 1.0:  # Buy signal
            entry_price = data.at[index, 'Price']
            exit_price = entry_price + (entry_price - data.at[index+1, 'Price']) * risk_reward_ratio
            data.at[index, 'Exit_Signal'] = exit_price

    return data

# Defining the entry signals
def moving_average_crossover(data, short_window=10, long_window=50):
    signals = pd.DataFrame(index=data.index)
    signals['Signal'] = 0.0
    signals['Short_MA'] = data['Price'].rolling(window=short_window, min_periods=1, center=False).mean()
    signals['Long_MA'] = data['Price'].rolling(window=long_window, min_periods=1, center=False).mean()
    signals['Signal'][short_window:] = np.where(signals['Short_MA'][short_window:] > signals['Long_MA'][short_window:], 1.0, 0.0)
    signals['Position'] = signals['Signal'].diff()
    return signals


def bollinger_bands_breakout(data, window=20, num_std_dev=2):
    signals = pd.DataFrame(index=data.index)
    signals['Signal'] = 0.0
    rolling_mean = data['Price'].rolling(window=window, min_periods=1, center=False).mean()
    rolling_std = data['Price'].rolling(window=window, min_periods=1, center=False).std()
    signals['Upper_Band'] = rolling_mean + (rolling_std * num_std_dev)
    signals['Lower_Band'] = rolling_mean - (rolling_std * num_std_dev)
    signals['Signal'][(data['Price'] > signals['Upper_Band']) | (data['Price'] < signals['Lower_Band'])] = 1.0
    signals['Position'] = signals['Signal'].diff()
    return signals

def rsi_divergence(data, window=14, threshold=30):
    signals = pd.DataFrame(index=data.index)
    signals['Signal'] = 0.0

    # Calculate RSI
    data['RSI'] = 100 - (100 / (1 + data['Price'].pct_change().rolling(window=window, min_periods=1).mean()))

    # Create signals based on RSI divergence
    signals['Signal'][data['RSI'] < threshold] = 1.0

    # Generate trading orders
    signals['Position'] = signals['Signal'].diff()

    return signals

def macd_histogram(data, short_window=12, long_window=26, signal_window=9):
    signals = pd.DataFrame(index=data.index)
    signals['Signal'] = 0.0

    # Calculate MACD
    data['Short_MA'] = data['Price'].rolling(window=short_window, min_periods=1, center=False).mean()
    data['Long_MA'] = data['Price'].rolling(window=long_window, min_periods=1, center=False).mean()
    data['MACD'] = data['Short_MA'] - data['Long_MA']
    data['Signal_Line'] = data['MACD'].rolling(window=signal_window, min_periods=1, center=False).mean()

    # Create signals based on MACD histogram
    signals['Signal'][data['MACD'] > data['Signal_Line']] = 1.0

    # Generate trading orders
    signals['Position'] = signals['Signal'].diff()

    return signals

def stochastic_oscillator(data, window=14, threshold=20):
    signals = pd.DataFrame(index=data.index)
    signals['Signal'] = 0.0

    # Calculate %K and %D for stochastic oscillator
    data['Lowest_Low'] = data['Price'].rolling(window=window, min_periods=1, center=False).min()
    data['Highest_High'] = data['Price'].rolling(window=window, min_periods=1, center=False).max()
    data['%K'] = 100 * ((data['Price'] - data['Lowest_Low']) / (data['Highest_High'] - data['Lowest_Low']))
    data['%D'] = data['%K'].rolling(window=3, min_periods=1, center=False).mean()

    # Create signals based on stochastic oscillator
    signals['Signal'][data['%K'] < threshold] = 1.0

    # Generate trading orders
    signals['Position'] = signals['Signal'].diff()

    return signals


# Defining different trading systems
def trading_system_1(data):
    entry_signals = moving_average_crossover(data, short_window=10, long_window=50)
    exit_signals = apply_exit_strategy(entry_signals)
    return exit_signals

def trading_system_2(data):
    entry_signals = bollinger_bands_breakout(data, window=20, num_std_dev=2)
    exit_signals = apply_exit_strategy(entry_signals)
    return exit_signals

def trading_system_3(data):
    entry_signals = rsi_divergence(data, window=14, threshold=30)
    exit_signals = apply_exit_strategy(entry_signals)
    return exit_signals

def trading_system_4(data):
    entry_signals = macd_histogram(data, short_window=12, long_window=26, signal_window=9)
    exit_signals = apply_exit_strategy(entry_signals)
    return exit_signals

def trading_system_5(data):
    entry_signals = stochastic_oscillator(data, window=14, threshold=20)
    exit_signals = apply_exit_strategy(entry_signals)
    return exit_signals


# Simulating trading for each system
system_1_results = trading_system_1(df)
system_2_results = trading_system_2(df)
system_3_results = trading_system_3(df)
system_4_results = trading_system_4(df)
system_5_results = trading_system_5(df)


