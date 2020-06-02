
require(dplyr)

# Desc:
#   Given seattle real estate data sets and user preferences, analyze the data and output data and 
#   charts of the analysis.  This is a compiler script of all the source functions and other 
#   necessary processes.
# Inpt:
#   - rpsDf [df]: Seattle RPS data set
#   - rbDf [df]: Seattle Residential Building data set
#   - latest_date [str]: string format of latest date to run analysis through in YYYY-mm-dd format
#   - topN [int]: number of visuals to output in order of top results
#   - save_wd [path]: path to save data and visuals
#   - data_wd [path]: path to load data
#   - visuals [str]: 'y' or 'n' for whether or not to save visuals
#   - save_df [str]: 'y' or 'n' to save data set as csv
# Oupt:
#   - finalDf [df]: final data set from analysis
#   - [visuals]: saved to save_wd path if user specified
seattle_rps_compiler <- function(rpsDf, rbDf, latest_date, topN, save_wd, data_wd, visuals, save_df){
  
  # Initial Processing
  script_endYear = as.numeric(format(as.Date(latest_date), "%Y"))
  rpsDf$DocumentDate <- as.Date(rpsDf$DocumentDate, "%m/%d/%Y")
  
  # Subset on 2007 because thats how far quantmod's stock prices go back on initial pull
  rpsDf <- rpsDf[rpsDf$DocumentDate > "2007-01-01" & rpsDf$DocumentDate < latest_date,]
  rpsDf$Years <- as.numeric(format(rpsDf$DocumentDate, "%Y"))
  
  # Use yearlyInflationRef
  rpsDf <- yearlyInflationRef(startYear = 2007, dataFrame = rpsDf, 
                              columnYearName = "Years", targetColumn = "SalePrice", inflationYear = script_endYear)
  
  # Create flags to remove rows with
  corpEntityFlag <- c(" corp.", " co.", " corp ", " co ", "corporation",
                      " llc.", "llc. ", " llc ", "llc.", "llc", "l l c", "l.l.c",
                      " inc.", " inc. ", " inc ", " inc", "incorporated",
                      " holdings ", " holdings",
                      " trust ", " trust", "trustee",
                      " ltd.", " ltd", " ltd.", "limited",
                      " bank", " city", " seattle")
  
  # Remove transactions with buyers who have any of the above corporate flags
  rpsDf <- removePartialStrings(dataFrame = rpsDf, stringVector = corpEntityFlag, targetColumn = "BuyerName")
  
  # Properties to exclude:
  #   - Luxury real estate: >$1m in current dollars
  rpsDf <- rpsDf[rpsDf[[paste0("SalePrice", script_endYear, "_Dollars")]] < 1000000,] # Non luxury data set
  
  #   - We will only look at sale vehicles of statutory warranty deeds: id = 3
  #   - To account for any other special warranties, we will remove transactions with $0 value
  rpsDf <- rpsDf[rpsDf$SaleInstrument == 3 & rpsDf[[paste0("SalePrice", script_endYear, "_Dollars")]] > 0,]
  
  # Prep arguments for subsetMerge function
  rbVec <- c("Major", "Minor", "Address", "ZipCode", "SqFtTotLiving", "Bedrooms", "BathFullCount", "YrBuilt")
  joinVec <- c("Major", "Minor")
  
  # Change rpsDf major minor to integer
  rpsDf$Major <- as.integer(rpsDf$Major)
  rpsDf$Minor <- as.integer(rpsDf$Minor)
  
  # Run subsetMerge function
  people_rbDf <- subsetMerge(dataFrame1 = rbDf, dataFrame2 = rpsDf, keepColumns = rbVec, joinColumns = joinVec)
  
  # Create a new column for bedroom bathroom
  people_rbDf$BedBath <- paste0(people_rbDf$Bedrooms, "-", people_rbDf$BathFullCount)
  
  # Run standardizeZipcode function on people_rbDf 
  people_rbDf <- standardizeZipcode(dataFrame = people_rbDf, targetColumn = "ZipCode", removeStatus = "Y")
  
  # Geocode all zip codes
  people_rbDfgeo <- geocodeZipcode(dataFrame = people_rbDf, "ZipCode")
  
  # Calculate bins of total sq ftge
  people_rbDfgeo <- calculateBins(people_rbDfgeo, "SqFtTotLiving")
  people_rbDfgeo$PPSqFt <- people_rbDfgeo[[paste0("SalePrice", script_endYear, "_Dollars")]]/people_rbDfgeo$SqFtTotLiving
  
  # Create a grouped data frame for these parameters:
  #		- SqFtTotLiving_Bins within each Zipcode
  #		- Broken out by years
  #		ex: 2007-2019 SqFt Bins by each zipcode
  #				- Note: Summarize the total transaction volume and average 
  
  # First group by zipcode -> sqftbins -> years
  groupDf <- people_rbDfgeo %>% group_by(ZipCode, Bedrooms, Years) %>% summarize(AvgSale = mean(!!as.name(paste0("SalePrice", script_endYear, "_Dollars"))),
                                                                                 TotalVolume = length(Address),
                                                                                 AvgPPSqFt = mean(PPSqFt)) 
  
  
  # Calculate the difference columns within each group 
  groupDf <- groupDf %>% arrange(Years) %>% group_by(ZipCode, Bedrooms) %>% 
    mutate(DiffVolume = (TotalVolume - lag(TotalVolume))/lag(TotalVolume),
           DiffAvgSale = (AvgSale - lag(AvgSale))/(lag(AvgSale)),
           CountYears = length(unique(Years)),
           TotalVolumeGrouping = sum(TotalVolume))
  
  # Now order the data set
  groupDf <- groupDf[with(groupDf, order(ZipCode, Bedrooms, Years)),]
  
  # Remove groups where there is less than n# for the years count
  groupDf <- groupDf[groupDf$CountYears == script_endYear-2007+1 & groupDf$TotalVolumeGrouping > 100 & groupDf$Years != 2007,]
  
  # Create data frame of stock tickers
  tickers <- c("ALK", "AMZN", 'BA', 'EXPE', 'JWN', 'MSFT', 'SBUX')
  stockDf <- createTickerDf(tickers)
  
  # Get period return for each stock
  # Amazon, Boeing, Microsoft, Alaska Airlines, Starbucks, Expedia, Nordstrom (JWN)
  yearlyAmznDelta <- as.numeric(periodReturn(stockDf$AMZN.Adjusted, period = "yearly"))
  yearlyBoeingDelta <- as.numeric(periodReturn(stockDf$BA.Adjusted, period = "yearly"))
  yearlyMsftDelta <- as.numeric(periodReturn(stockDf$MSFT.Adjusted, period = "yearly"))
  yearlyAlkDelta <- as.numeric(periodReturn(stockDf$ALK.Adjusted, period = "yearly"))
  yearlySbuxDelta <- as.numeric(periodReturn(stockDf$SBUX.Adjusted, period = "yearly"))
  yearlyJwnDelta <- as.numeric(periodReturn(stockDf$JWN.Adjusted, period = "yearly"))
  yearlyExpeDelta <- as.numeric(periodReturn(stockDf$EXPE.Adjusted, period = "yearly"))
  
  # Bind these back into a data frame
  stockDfYrReturn <- as.data.frame(cbind("Years" = seq(2007, format(Sys.Date(), "%Y"), 1),
                                         "AMZN" = yearlyAmznDelta,
                                         "BA" = yearlyBoeingDelta,
                                         "MSFT" = yearlyMsftDelta,
                                         "ALK" = yearlyAlkDelta,
                                         "SBUX" = yearlySbuxDelta,
                                         "JWN" = yearlyJwnDelta,
                                         "EXPE" = yearlyExpeDelta),
                                   stringsAsFactors = FALSE)
  
  # Merge the the stock prices into our groupDf
  # This will be our final data frame 
  analysisDf <- groupDf %>% inner_join(stockDfYrReturn, by = "Years")
  
  #----------------#
  # Begin analysis #
  #----------------#
  
  # Keep only groupings of transactions (zipcode + beds) that has at least 10 transactions per
  # year for all years 2008 - current year
  keep <- colnames(analysisDf)[1:10]
  analysisDf_melt <- reshape2::melt(analysisDf, id.vars = keep, variable.name = "Stocks", value.name = "DiffAvgPrice")
  analysisDf_melt$Stocks <- as.character(analysisDf_melt$Stocks)
  
  # Alternate analysis, calculate integral of curves to get area between them, lower the area the better the score
  analysisDf_melt$UID <- paste0(analysisDf_melt$ZipCode, "-", analysisDf_melt$Bedrooms, "-", analysisDf_melt$Stocks)
  
  # Scale the two differences so sd of 1 and mean of 0
  analysisDf_melt <- analysisDf_melt %>% group_by(UID) %>% mutate(DiffAvgSale_S = written_scale(DiffAvgSale),
                                                                  DiffAvgPrice_S= written_scale(DiffAvgPrice))
  
  # Run integral analysis on data and create correlation column
  analysisDf_melt = integral_analysis(analysisDf_melt, startYear = 2008, endYear = script_endYear)
  
  # Order final data frame to view in tabular format
  finalDf <- analysisDf_melt[with(analysisDf_melt, order(-Correlation)),]
  
  # Create charts for top #n if user specifies it
  if (tolower(visuals) == "y"){
    
    # Select columns to plot
    columns = c("DiffAvgSale_S", 'DiffAvgPrice_S')
    
    # Loop through user specifed top #n results and plot them then save to save_wd working directory
    for (i in unique(finalDf$UID)[1:topN]){
      plot_dygraph_ts_chart(df = finalDf, uid = i, columns = columns, wd_path = save_wd)
    }
    
  }
  
  # If user specified to save data set, save it
  setwd(save_wd)
  if (tolower(save_df) == "y"){
    write.csv(finalDf, paste0("Seattle_RPS_Output_", Sys.Date()), ".csv", row.names = FALSE)
  }
  
}