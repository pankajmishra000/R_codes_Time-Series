# R_codes_Time-Series
Forecasting – ARIMA Time Series Models

ARIMA - Auto-Regressive(p) Integrated(d) Moving Average(q)-  time series forecasting models are very popular, adaptive, flexible models, which utilize historical information to make predictions of a value into the future. 

Time series analysis can not only be used in various business applications for forecasting a quantity into the future, and explaining its historical patterns;  examples:
Estimating the effect of a newly launched product line or a product. 
Predicting the price value of stocks. 
Forecasting and predicting seasonal patterns in a product / services sales.

ARIMA - Auto-Regressive(p) Integrated(d) Moving Average(q)

The forecast package allows you to specify the order of the model using the arima() function. 
E.g: arima(1,0,1)

One can choose to automatically generate a set of optimal (p, d, q) values using auto.arima(), which searches through various combinations of order parameters, and selects the optimal values. auto.arima() also allows the user to specify maximum order for (p, d, q), which is set to 5 by default.

The building blocks of a time series analysis are seasonality, trend, and cycle.
Seasonality refers to fluctuations in the data related to calendar cycles.
Cycle components refers the non-seasonal patterns in the data.
Trend refers to the overall patterns in the data series.
Residual or Error is a part of the time series that can't be attributed to seasonal, cycle, or trend components. 

STL is a function for decomposing and forecasting the series. Once can calculate seasonal component of the data using stl() using smoothing. It by default assumes additive model structure.

Since ARIMA uses previous lags of series to model its behavior, modeling stable series with consistent properties involves less uncertainty.

Fitting an ARIMA model requires the series to be stationary meaning its mean, variance, and auto-co variance are time invariant.  
