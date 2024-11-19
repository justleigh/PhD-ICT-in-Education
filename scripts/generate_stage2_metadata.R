# Load necessary libraries
library(dplyr)
library(readr)

# Define PISA years to process
years <- c(2000, 2003, 2006, 2009, 2012, 2015, 2018, 2022)

# Function to load Stage 1 and Stage 2 cleaned data
load_cleaned_data <- function(year, stage) {
  file_path <- paste0("data/processed/", year, "/pisa", year, "_cleaned_", stage, ".csv")
  data <- read_csv(file_path)
  return(data)
}

# Function to log metadata
log_metadata <- function(year, changes) {
  # Create year-specific metadata folder if it doesn't exist
  metadata_folder <- paste0("data/metadata/changes/", year)
  if (!dir.exists(metadata_folder)) {
    dir.create(metadata_folder, recursive = TRUE)
  }
  
  # Define file path for metadata log
  metadata_file <- paste0(metadata_folder, "/stage2_metadata_", year, ".csv")
  
  # Save metadata changes to CSV
  write_csv(changes, metadata_file)
  cat(sprintf("Metadata for year %d saved to %s\n", year, metadata_file))
}

# Process each year to generate metadata for Stage 2 cleaning
for (year in years) {
  # Load Stage 1 and Stage 2 cleaned data
  stage1_data <- load_cleaned_data(year, "stage1")
  stage2_data <- load_cleaned_data(year, "stage2")
  
  # Identify Dropped Variables
  dropped_vars <- setdiff(names(stage1_data), names(stage2_data))
  dropped_metadata <- data.frame(
    Variable_Name = dropped_vars,
    Change_Type = "Dropped",
    Change_Description = "Removed due to >50% missing data",
    Reason_Method = "Missingness"
  )
  
  # Identify Variables Imputed
  numeric_vars <- names(stage2_data)[sapply(stage2_data, is.numeric)]
  categorical_vars <- names(stage2_data)[sapply(stage2_data, is.character)]
  
  numeric_imputed <- data.frame(
    Variable_Name = numeric_vars,
    Change_Type = "Imputed (Numeric)",
    Change_Description = "Replaced missing values with median",
    Reason_Method = "Imputation"
  )
  
  categorical_imputed <- data.frame(
    Variable_Name = categorical_vars,
    Change_Type = "Imputed (Categorical)",
    Change_Description = "Replaced missing values with mode",
    Reason_Method = "Imputation"
  )
  
  # Identify Altered Variables (if applicable)
  # Example: Converting a variable like "gender" to a factor
  altered_metadata <- data.frame(
    Variable_Name = c("gender"), # Add any other known altered variables here
    Change_Type = "Altered",
    Change_Description = "Converted to factor with levels 'Female' and 'Male'",
    Reason_Method = "Standardization"
  )
  
  # Combine all metadata changes
  metadata_changes <- bind_rows(dropped_metadata, numeric_imputed, categorical_imputed, altered_metadata)
  
  # Save metadata log for this year
  log_metadata(year, metadata_changes)
}