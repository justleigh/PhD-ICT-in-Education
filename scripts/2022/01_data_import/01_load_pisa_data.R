# Load necessary library
library(readr)

# Function to dynamically load the PISA data for a specified year by constructing the file path based on the year argument
load_pisa_data <- function(year) {
  # Define file path dynamically
  csv_path <- paste0("data/raw/", year, "/pisa", year, "_data.csv")
  # Read the CSV
  pisa_data <- read_csv(csv_path)
  return(pisa_data)
}