
require(htmlwidgets)
require(webshot)
require(dygraphs)

# Desc:
#		Given data frame output of seattle rps analytics, output interactive
#		time series chart of stock price vs. real estate price % change using 
#		dygraphs
# Inpt:
#		- df [df]: data frame from the repo's analysis process
#		- uid [str]: string value of a uid that you want to plot
#		- columns [vec]: vector of columns to plot
#			- Both should be DiffAvg_S, DiffSale_S unless user customzied something
#		- wd_path [str]: wd path to save viz to
# Oupt:
#		- [saved image]: saved interactive dygraphs ts chart to wd_path
plot_dygraph_ts_chart <- function(df, uid, columns, wd_path){

	# Subset data frame to uid
  plotdf <- df[df$UID == uid,]
  plotdf2 <- subset(plotdf, select = columns)

  # Create ts version of data frame
  curplotdf <- ts(plotdf2, start = 2008)

  # Declare visualization variables
  curCompany <- unique(plotdf$Stocks)
  curZipCode <- unique(plotdf$ZipCode)
  curBedroom <- unique(plotdf$Bedrooms)

  # Create main title of viz
  mainTitle <- paste0("Yearly ", curZipCode, " ", curBedroom, " Bedroom Sale v. ", curCompany, " Stock Trends")

  # Create label title
  labelTitle <- paste0(curCompany, " Yearly Stock Price Percent Change")

  # Create dygraphs plot
  plot1 <- dygraph(curplotdf, main = mainTitle) %>%
    dyOptions(strokeWidth = 3) %>%
    dyAxis('x', drawGrid = FALSE) %>%
    dyAxis('y', label = "Scaled Average Price % Change", independentTicks = TRUE) %>%
    dyAxis('y2', label = "Scaled Stock Price % Change", independentTicks = TRUE) %>%
    dySeries("DiffAvgPrice_S", label = labelTitle, axis = ("y")) %>%
    dySeries("DiffAvgSale_S", label = "Yearly Average Sale Price Difference", axis = ("y"))
  
  # Create file name to save as
  curFileName <- paste0(wd_path, "/", mainTitle, ".png")

  # Save temp plot and updaet with parameters and new file name
  saveWidget(plot1, "temp.html", selfcontained = FALSE)

  # Set width/height
  width <- 1080
  height <- 610

  # Finalize file as filename
  webshot("temp.html", file = curFileName,
          cliprect = c(10,30,width+50, height+50), 
          vwidth = width, vheight = height)


}

