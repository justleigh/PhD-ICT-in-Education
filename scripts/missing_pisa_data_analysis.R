# Function to identify and summarize missing data for each year of PISA data
missing_data_summary <- function(year) {
  pisa_data <- load_pisa_data(year)
  
  # Calculate missing data percentage for each variable
  missing_data <- sapply(pisa_data, function(x) sum(is.na(x)) / length(x) * 100)
  missing_summary <- data.frame(Variable = names(missing_data), Missing_Percentage = missing_data)
  
  # Save missing data summary to CSV
  missing_summary_file <- paste0("data/metadata/data_exploration/", year, "_missing_data_summary.csv")
  write.csv(missing_summary, missing_summary_file, row.names = FALSE)
}

# Loop through each year to analyze and save missing data summaries
years <- c(2000, 2003, 2006, 2009, 2012, 2015, 2018, 2022)
for (year in years) {
  missing_data_summary(year)
}