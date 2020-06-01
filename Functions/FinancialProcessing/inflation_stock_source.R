require(quantmod)
require(dplyr)
require(data.table)

# Desc: 
#   This function takes in a vector of stock tickers to merge into a data frame 
#   that contains the daily adjusted prices and trading volume
# Inpt:
#   - tickers [vector]: stock ticker values to create a data frame out of
# Oupt:
#   - mergeDf [df]: data frame of stock tickers and adjust price and volume values
createTickerDf <- function(tickers){

  # Set up environment to create df
  stockEnv <- new.env()
  getSymbols(tickers, env = stockEnv)
  
  # Create adjusted price
  stockList <- eapply(stockEnv, Ad) #Ad pulls in the adjusted price of the stock
  stockDf <- do.call(merge, stockList)
  
  # Create volume
  stockListVol <- eapply(stockEnv, Vo)
  stockVol <- do.call(merge, stockListVol)
  
  # Merge data frames
  mergeDf <- cbind(stockDf, stockVol)
  
  return(mergeDf)
  
}


# Desc:
#   Given data frame of prices and corresponding year of price, convert
#   to a user input year dollars.
# Inpt:
#   - startYear [int]: earliest year for prices
#   - dataFrame [df]: data frame of prices and years
#   - columnYearName [str]: name of df column that corresponds to year
#   - targetColumn [str]: name of df column that corresponds to price
#   - inflationYear [int]: user specifed year to convert prices to
# Oupt:
#   - dataFrame [df]: updated data frame with prices adjusted to user
#                     defined year dollars
yearlyInflationRef <- function(startYear, dataFrame, columnYearName, targetColumn, inflationYear){
  
  require(quantmod)
  
  # Get CPI to calculate inflation rates
  getSymbols("CPIAUCSL", src='FRED')
  
  # Apply a yearly function to get the yearly inflation
  avgCPI <- apply.yearly(CPIAUCSL, mean)
  
  # Filter paste
  filter <- paste0(startYear, "::")
  
  # Subset to startYear based on real estate data
  avgCPI <- avgCPI[filter]
  
  # Calcualte conversion factor
  conversion <- as.vector(as.numeric(avgCPI[inflationYear])/avgCPI)
  years <- seq(startYear, 2019, 1)
  
  # Inflation data frame
  inflDf <- as.data.frame(cbind(years,
                                "InflConversionFactor" = conversion),
                          stringsAsFactors = FALSE)
  colnames(inflDf)[1] <- columnYearName
  
  dataFrame <- dataFrame %>% inner_join(inflDf, by = columnYearName)
  
  newTargetColName <- paste0(targetColumn, paste0(inflationYear, "_Dollars"))
  
  dataFrame[,newTargetColName] <- dataFrame[,targetColumn] * dataFrame$InflConversionFactor
  
  return(dataFrame)
  
}
