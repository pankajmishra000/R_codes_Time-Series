getwd() #just to make sure about your working directory
#you can make your own arrangements, best suited for your import of data

#######  ARIMA MODEL For Temperature ##########

library(readr) # make sure to install this library
library(tseries)
library(forecast)
library(ggplot2)
day <- read_csv("E:/R/sentiment analysis/Time_series_ARIMA/day.csv")
summary(day) # to check the summary

str(day) # to check the structure of each class
day$Date = as.Date(day$dteday)
ggplot(day, aes(x = dteday, y = cnt))+geom_line()+scale_x_date('mnth')+ylab("Daily Bike Checkout")


#Remove outliers to smooth series

no_outliers = ts(day$cnt)
day$smoothed_rental=tsclean(no_outliers)
#plotting smoothed data
ggplot(day, aes(x = dteday, y = smoothed_rental))+geom_line()+scale_x_date('mnth')+ylab("Daily Bike Checkout")
#we can aso check the changes in data in excel by writing the above dataframe in csv

day$sevday_MA = ma(day$smoothed_rental, order=7)
day$thirtyday_MA = ma(day$smoothed_rental,order =30)

ggplot() + geom_line(data = day, aes(x = dteday, y = smoothed_rental, colour="Rentals")) +
          geom_line(data = day, aes(x = dteday, y = sevday_MA, colour="7_day Rental"))+
          geom_line(data = day, aes(x = dteday, y = thirtyday_MA, colour="30 day Rentals"))
rental_ma = ts(na.omit(day$sevday_MA), frequency = 30)
decomp_rental = stl(rental_ma, s.window = "periodic")
plot(decomp_rental)

adj_rental= seasadj(decomp_rental)
plot(adj_rental)

#ARIMA

fit = arima(adj_rental, order=c(1,1,5)) 
fcast_arima = forecast(fit,h=30)
plot(fcast_arima)

#AUTO ARIMA, it automatically chooses the parameters and returns the best fitted model
fit2 = auto.arima(adj_rental, seasonal = FALSE)
fcast_autoarima = forecast(fit2, h=30)
plot(fcast_autoarima)

#AUTO ARIMA Seasonal Forecating
fit2_s = auto.arima(adj_rental, seasonal = TRUE)
fcast_autoarima_s = forecast(fit2_s, h=30)
plot(fcast_autoarima_s)
