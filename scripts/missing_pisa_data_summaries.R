# List of PISA years to process
years <- c(2000, 2003, 2006, 2009, 2012, 2015, 2018, 2022)

# Function to dynamically load PISA data for a given year
load_pisa_data <- function(year) {
  csv_path <- paste0("data/raw/", year, "/pisa", year, "_data.csv")
  pisa_data <- read.csv(csv_path)
  return(pisa_data)
}

# Loop through each year to calculate missing data summaries and save to metadata folder
for (year in years) {
  # Load data for the specific year
  pisa_data <- load_pisa_data(year)
  
  # Calculate percentage of missing data for each variable
  missing_data_summary <- sapply(pisa_data, function(x) sum(is.na(x)) / length(x) * 100)
  missing_data_summary <- data.frame(Variable = names(missing_data_summary),
                                     Missing_Percentage = missing_data_summary)
  
  # Save missing data summary as a CSV file in the metadata/missing_data_summaries folder
  summary_file <- paste0("data/metadata/missing_data_summaries/", year, "_missing_data_summary.csv")
  write.csv(missing_data_summary, summary_file, row.names = FALSE)
}
