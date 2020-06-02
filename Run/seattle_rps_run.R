
# Remove all variables
rm(list=ls())

# Preset Variables for run script
latest_date = "YYYY-mm-dd" # Enter date here
save_wd = ""
data_wd = ""

# Load all source script functions
source("~/GitHub/seattle-rps-analysis/Functions/FinancialProcessing/inflation_stock_source.R")
source("~/GitHub/seattle-rps-analysis/Functions/Geocoding/zipcode_geocode_source.R")
source("~/GitHub/seattle-rps-analysis/Functions/RPSProcessing/seattle_rps_source.R")
source("~/GitHub/seattle-rps-analysis/Functions/Analytics/price_integral_source.R")
source("~/GitHub/seattle-rps-analysis/Functions/Visualizations/price_comparison_source.R")
source("~/GitHub/seattle-rps-analysis/Run/seattle_rps_compiler.R")

# Load in data to start for full-run
setwd(data_wd)

# Initial Processing
rpsDf <- fread("EXTR_RPSale.csv", stringsAsFactors = FALSE)
rbDf <- fread("EXTR_ResBldg.csv", stringsAsFactors = FALSE)

seattle_rps_compiler(rpsDf = rpsDf, rbDf = rbDf, 
                     latest_date = latest_date, topN = 10, 
                     save_wd = save_wd, data_wd = data_wd, 
                     visuals = 'y', save_df = 'y')
