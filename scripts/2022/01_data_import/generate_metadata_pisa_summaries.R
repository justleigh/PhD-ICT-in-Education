# Load necessary library
library(readr)

# Define a function to dynamically load the PISA data for a specified year
load_pisa_data <- function(year) {
  # Define the file path dynamically based on the year
  csv_path <- paste0("data/raw/", year, "/pisa", year, "_data.csv")
  # Read the CSV file
  pisa_data <- read_csv(csv_path)
  return(pisa_data)
}

# List of years you have PISA data for
years <- c(2000, 2003, 2006, 2009, 2012, 2015, 2018, 2022)

# Loop through each year, load the data, and save structure and summary
for (year in years) {
  # Load data for the current year
  pisa_data <- load_pisa_data(year)
  
  # Create a subfolder for each year in data/metadata/data_exploration if it doesn't exist
  year_folder <- paste0("data/metadata/data_exploration/", year)
  if (!dir.exists(year_folder)) {
    dir.create(year_folder, recursive = TRUE)
  }
  
  # Save structure as a .txt file in the year-specific folder
  structure_file <- paste0(year_folder, "/", year, "_structure.txt")
  capture.output(str(pisa_data), file = structure_file)
  
  # Save summary as a .csv file in the year-specific folder
  summary_file <- paste0(year_folder, "/", year, "_summary.csv")
  write.csv(summary(pisa_data), summary_file)
  
  # Print a message indicating completion for the current year
  cat(sprintf("Structure and summary files saved for %d.\n", year))
}