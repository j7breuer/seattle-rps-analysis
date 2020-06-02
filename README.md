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
install.packages(zipcode)
install.packages(data.table)
install.packages(quantmod)
install.packages(qdapRegex)
install.packages(htmlwidgets)
install.packages(webshot)
```

## Author
J Breuer - j7breuer@gmail.com.  Please reach out with any questions.

## Updates
Please reach out with analysis ideas, I've got a few but have not gotten around to them yet. 
