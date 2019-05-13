library(readr)
library(tseries)
library(forecast)
library(ggplot2)
options(warn=-1)

# Change the value of the path as per the location of the dataset in your local machine
path = "D:\\Extra\\R\\PID0003\\Input\\LINUX-CPU-201902-201903.csv"

# Readind data in R environment
LINUX_CPU <- read_delim(path,";", escape_double = FALSE, col_types = cols(TIMESTAMP = col_datetime(format = "%d-%m-%y %H:%M")), 
                                      trim_ws = TRUE)

# Want to view the data, uncomment the below command
# View(LINUX_CPU)  

# Extracting unique cpus
servers = as.vector(unique(LINUX_CPU$SERVER_NAME))

# As ARIMA is univariate model, we will just use the single column for the average used cpu
# Dropping other unncessary columns
LINUX_CPU = LINUX_CPU[-c(4,5)]

# Generic plot for all the server usage over time
# Plotting the data
print(gg1 <- ggplot(data = LINUX_CPU) +
        aes(x = TIMESTAMP, y = AVG_USED_CPU_PCT, color = SERVER_NAME) +
        geom_line() +
        labs(title = "ALL- Server Plot of the Time Series",
             x = "Time",
             y = "AVG_USED_CPU") +
        
        theme(legend.position = 'bottom'))
Sys.sleep(0.3)
name = paste("All cpu time series plot",".png", sep = "-")
ggsave(name, device = "png")
Sys.sleep(0.1)

# Facet plot for all the cpu usage pattern over time
print(gg2 <- ggplot(data = LINUX_CPU) +
        aes(x = TIMESTAMP, y = AVG_USED_CPU_PCT) +
        geom_line(color = "#0c4c8a") +
        labs(title = "ALL- Server Plot of the Time Series",
             x = "Time",
             y = "AVG_USED_CPU") +
        
        facet_wrap(vars(SERVER_NAME)))
Sys.sleep(0.3)
name = paste("All cpu time series plot facet",".png", sep = "-")
ggsave(name, device = "png")
Sys.sleep(0.1)

################### All PLOTs and FINAL 19 MODEL's from this loop ###################
 for (i in 1:19) {

# As we need to build 19 ARIMA models, for each of the servers, we need to separate the data for each server

data.cpu =subset(LINUX_CPU, LINUX_CPU$SERVER_NAME== servers[i] , select = c("TIMESTAMP", "AVG_USED_CPU_PCT"))

#Plotting specific to the servers
print(gg3 <-ggplot(data = data.cpu) +
  aes(x = TIMESTAMP, y = AVG_USED_CPU_PCT) +
  geom_line() +
  labs(title = paste(servers[i]," Plot - Time Series", sep = " "),
       x = "Time",
       y = "AVG_USED_CPU"))

Sys.sleep(0.2)
name = paste("Time Series plot for -",servers[i], ".png", sep = "-")
ggsave(name, device = "png")
Sys.sleep(0.5)


# Checking the stationarity of the series
val.p= adf.test(data.cpu$AVG_USED_CPU_PCT)
flag =0
if  (val.p$p.value <=0.5){
  print("Series is Stationary")
} else { 
  flag =1
  print ("Series is not stationary")}

# As series is stationary, we can directly move forward to the ARIMA model.
# Let's check the ACF and PACF plot to know the autocorrelation affect.

graphics.off()
plot.new()
a <-acf(data.cpu$AVG_USED_CPU_PCT) # It shows the effect of autocorrelation
png(paste("acf",servers[i],".png", sep="-"))
plot(a)
dev.off()
p <- pacf(data.cpu$AVG_USED_CPU_PCT) # Lag is found till the lag of 27
png(paste("pacf",servers[i],".png", sep="-"))
plot(p)
dev.off()

######### ARIMA MODEL ########
model.arima = auto.arima(data.cpu$AVG_USED_CPU_PCT, seasonal = TRUE)
summary(model.arima)

forecasted.values =forecast(model.arima, h = 48)

write.csv(forecasted.values, file = paste("forecasted",servers[i],".csv", sep = "-"))

graphics.off()
plot.new()

png(paste("forecasted_value",servers[i],".png", sep="-"))
plot(forecasted.values, col = "cyan")
dev.off()
}

