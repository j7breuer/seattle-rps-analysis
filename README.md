# Corporate Impact on Seattle's Real Estate Market
<b>Disclaimer: This repository is used for my undergraduate economics course, the repo's code is not the most efficient as it is used in class to teach certain principles and demonstrate various ways to achieve the same desired output.</b>

This repository contains a process of data cleaning, processing, analytics, and visualizations to determine the impact of companies in the Seattle real estate market.  Time period for analysis runs from 2008 to user-defined year.  <b> Recommended time period is 2008 - 2019 (pre COVID-19) </b>.  Corporations included in analysis are:
- Amazon (AMZN)
- Boeing (BA)
- Microsoft (MSFT)
- Starbucks (SBUX)
- Alaska Airlines (ALK)
- Expedia (EXPE)
- Nordstrom (JWN)

The output of the analysis is user-defined as either a CSV file of analysis or time-series charts comparing stock price changes and real estate price changes.

## Data Download
For this analysis, two data sets are required.  These data sets are maintained by the [King County Department of Assessments](https://info.kingcounty.gov/assessor/DataDownload/default.aspx).  
### Steps to download data
1. Navigate to url above
2. Check 'acknowledgement' box
3. Select 'Real Property Sales (.ZIP)' and 'Residential Building (.ZIP)' - download should begin
4. Unzip both files into a data directory
5. Use data dirctory for 'data_wd' variable path in code

## Installation
To get started with this short-ETL/analytics pipeline, please clone the repo and navigate to the Run/seattle_rps_run.R script. The run script is below with comments on input:

```R
require(data.table)

latest_date = "YYYY-mm-dd" # Enter user-defined end date of analysis (2019-12-31 is recommended for prior to COVID-19).
save_wd = "" # Enter working directory to save output to
data_wd = "" # Enter working directory that has input data

# Source functions from repo
source("~/GitHub/seattle-rps-analysis/Functions/FinancialProcessing/inflation_stock_source.R")
source("~/GitHub/seattle-rps-analysis/Functions/Geocoding/zipcode_geocode_source.R")
source("~/GitHub/seattle-rps-analysis/Functions/RPSProcessing/seattle_rps_source.R")
source("~/GitHub/seattle-rps-analysis/Functions/Analytics/price_integral_source.R")
source("~/GitHub/seattle-rps-analysis/Functions/Visualizations/price_comparison_source.R")
source("~/GitHub/seattle-rps-analysis/Run/seattle_rps_compiler.R")

# Set your working directory to load the data
setwd(data_wd)

# Load data
rpsDf <- fread("EXTR_RPSale.csv", stringsAsFactors = FALSE)
rbDf <- fread("EXTR_ResBldg.csv", stringsAsFactors = FALSE)

# Run the compiler 
seattle_rps_compiler(rpsDf = rpsDf, rbDf = rbDf, 
                     latest_date = latest_date, topN = 10, # Set topN to however many charts you want outputted in order of best results 
                     save_wd = save_wd, data_wd = data_wd, 
                     visuals = 'y', save_df = 'y') # Set visauls/save_df to 'y' or 'n' if you want data and visual output saved
```
## R Dependencies
```R
install.packages(dplyr)
install.packages(dygraphs)
install.packages(data.table)
install.packages(quantmod)
install.packages(qdapRegex)
install.packages(htmlwidgets)
install.packages(webshot)
```

## R Zipcode Package - CRAN Removal
This code uses the zipcode package in R which has now been removed, to download and install please navigate to this to this [link](https://cran.r-project.org/src/contrib/Archive/zipcode/).  Download the zipcode_1.0.tar.gz and store it in a directory of your choice.  Run the following code with the directory in place of 'path/to/zipcode/download':
```R
install.packages("path/to/zipcode/download", repos = NULL, type = "source")
```

## Analytics Pipeline Steps
1. Load in data and subset to user-defined data range
2. Roughly subset the data to purchases made by the labor market as opposed to real estate companies buying/selling/flipping houses
3. Adjust prices for inflation based on end year - if user specified timeline till 2018-01-01, real estate prices will be in 2018 dollars
4. Enrich data set with property specs (bedroom count, total square footage, etc.)
5. Clean and process zipcodes as a field to group on
6. Group data set by zipcodes, bedroom-bath count, and by years to get volume of transactions and avg/total sale price
7. Create Stock data set for companies listed above, join on data set by years
8. Calculate percentage change YoY for average sale price and stock price, standardize data for integral
9. Calculate integral between time series chart to get area between two lines and run correlation on lines as methods for analysis
10. Return/plot data in order of highest score ([-1, 1] scale)

## Covid-19 Impact on Analysis
Seattle's real estate market slowed down drastically between January-March of 2020, it is recommended to run analysis up until end of 2019.

## Author
J Breuer - j7breuer@gmail.com.  Please reach out with any questions.

## Updates
Please reach out with analysis ideas, I've got a few but have not gotten around to them yet.  Would be interested to incorporate Fourier's transformations as a means of analysis.
