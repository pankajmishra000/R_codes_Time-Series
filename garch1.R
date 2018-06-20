set.seed(123)
#Libraries

library(quantmod)
library(tseries)
library(fGarch)
library(rugarch)
date.start <- "2010-01-01"
date.end <- "2012-12-31"
getSymbols("AAPL", from = date.start, to = date.end, src = "yahoo")
head(AAPL)
tail(AAPL)
plot(AAPL$AAPL.Close)

#to check the stationarity of the time series corresponding to closing price 

adf.test(log(AAPL$AAPL.Close)) #check the P-values, it's > 0.05

#Taking the log return and making series stationary by differencing

log.return = diff(log(AAPL$AAPL.Close))

#to remove the NA values. We get NA value for the first row because of differencing and log return
log.return = log.return[-1,]

#Again checking the stationarity of the log-differenced-series for closing price
adf.test(log.return) #results shows unit root is not present in the series. P values <0.05

#test to check if the series has serial correlation
Box.test(log.return, type = "Ljung-Box")#results shows data exhibit serial correlation. P value>0.05


plot(diff(log(AAPL$AAPL.Close)))
acf(log.return^2)
pacf(log.return^2)


#Fitting ARIMA model
final.fit.aic <- Inf
final.fit.order <- c(0,0,0)
for (p in 1:5) for (d in 0:1) for (q in 1:5) {
   current.fit.aic <- AIC(arima(log.return, order=c(p, d, q), seasonal = list(order = c(0, 0, 0), period = 5)))
   if (current.fit.aic < final.fit.aic) {
       final.fit.aic <- current.fit.aic
       final.fit.order <- c(p, d, q)
       final.fit.arima <- arima(log.return, order=final.fit.order)
     }
 }
#fetching final order
final.fit.order
AIC(final.fit.arima)

acf(resid(final.fit.arima))
acf(resid(final.fit.arima)^2)
pacf(resid(final.fit.arima)^2)
qqnorm(resid(final.fit.arima))
#GARCH fitting using Rugarch
aapl1 <- ugarchspec(variance.model = list(model = "sGARCH",garchOrder = c(1,1)),
                    mean.model = list(armaOrder = c(4,4)),distribution.model = "std")
aaplGarch1 <- ugarchfit(spec = aapl1, 
                        data = AAPL$AAPL.Close,
                        fit.control = list(stationarity = 1, 
                                           fixed.se = 0, scale = 0, 
                                           rec.init = 'all',
                                          trunclag = 1000))
aaplGarch1

#Forecasting using the GARCH MODEL

aaplPredict1 <- ugarchboot(aaplGarch1, n.ahead = 10,method = c("Partial","Full")[1])
aaplPredict1
plot(aaplPredict1,which = 2) 


#Comparison between extracted data for 10 days and predicted data for 10 days
date.start <- "2013-01-01"
date.end <- "2013-01-16"
apple2= getSymbols("AAPL", from = date.start, to = date.end, src = "yahoo")
nrow(AAPL)
match = cbind(AAPL$AAPL.Close,aaplPredict1@forc@forecast$seriesFor)
plot(match)
