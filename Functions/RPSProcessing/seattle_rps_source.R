require(qdapRegex)
require(dplyr)
require(data.table)

# Desc:
#   Given a data frame and a column of string values, remove rows that contain
#   any sequence of string values.
# Inpt:
#   - dataFrame [df]: input data frame
#   - stringVector [vec]: vector of string values to find and remove rows on
#   - targetColumn [str]: string format of column name to search through
# Oupt:
#   - dataFrame [df]: subsetted data frame
removePartialStrings <- function(dataFrame, stringVector, targetColumn){
  
  require(qdapRegex)
  
  # Standardize string column to lowercase with no extra white space
  dataFrame[[targetColumn]] <- tolower(dataFrame[[targetColumn]])
  dataFrame[[targetColumn]] <- rm_white_multiple(dataFrame[[targetColumn]])
  stringVector <- tolower(stringVector)
  
  # Loop through vector of unwanted values and filter data set each iteration
  for (i in stringVector){

    # Remove transactions for seller name  
    dataFrame <- dataFrame[!grepl(i, dataFrame[[targetColumn]]),]
    
  }
  
  return(dataFrame)
  
}


# Desc:
#   Given two data frames and multiple columns to inner join on,
#   perform the merge 
# Inpt:
#   - dataFrame1 [df]: first data frame
#   - dataFrame2 [df]: second data frame
#   - keepColumns [vec]: vector of columns to subset df1 to
#   - joinColumns [vec]: vector of columns to inner join on
# Oupt:
#   - mergeDataFrame [df]: merged and potentially subsetted df
subsetMerge <- function(dataFrame1, dataFrame2, keepColumns, joinColumns){

  require(dplyr)

  # Subset the columns down to what the user specifies in 'keepColumns'
  subDataFrame1 <- subset(dataFrame1, select = keepColumns)
  # inner_join data sets together
  mergeDataFrame <- subDataFrame1 %>% inner_join(dataFrame2, by = joinColumns)
  # return back to user
  return(mergeDataFrame)

}



# Desc:
#   Given data frame and square footage column of real estate properties,
#   create sq footage bins of properties in 1000 sq ft increments
#   up until 5000 sq ft, at which point >5000 sq ft is the last bin
# Inpt:
#   - dataFrame [df]: input data frame
#   - targetColumn [str]: string format of real estate sq footage column
calculateBins <- function(dataFrame, targetColumn){
  
  newColName <- paste0(targetColumn, "_Bins")
  dataFrame[[newColName]] <- NA
  
  dataFrame[[newColName]][dataFrame[[targetColumn]] <= 1000] <- 1
  dataFrame[[newColName]][dataFrame[[targetColumn]] > 1000 & dataFrame[[targetColumn]] <= 2000] <- 2
  dataFrame[[newColName]][dataFrame[[targetColumn]] > 2000 & dataFrame[[targetColumn]] <= 3000] <- 3
  dataFrame[[newColName]][dataFrame[[targetColumn]] > 3000 & dataFrame[[targetColumn]] <= 4000] <- 4
  dataFrame[[newColName]][dataFrame[[targetColumn]] > 4000 & dataFrame[[targetColumn]] <= 5000] <- 5
  dataFrame[[newColName]][dataFrame[[targetColumn]] > 5000 ] <- 6
  
  return(dataFrame)
  
}

# Desc:
#   Function to scale a vector of numeric values
# Inpt:
#   - x [vec]: vector of numeric values to scale
# Oupt: 
#   - [vec]: scaled vector
written_scale <- function(x){
  #(x - mean(x, na.rm = TRUE))/sd(x, na.rm=TRUE)
  scale(x, scale = FALSE)
}