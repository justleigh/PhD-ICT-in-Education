# --------------------------------------
# PISA 2022 Initial Data Cleaning and Removal of High-Missingness Variables
# --------------------------------------
# Purpose:
# - Remove well-being variables that are not relevant to the research focus.
# - Identify and exclude variables with 100% missing data to improve dataset usability.
# - Ensure consistency in variable selection by applying structured filtering criteria.
# - Create a cleaning log to document removed variables for reproducibility and transparency.
# - Save the cleaned dataset for subsequent transformation and standardization.

# Load necessary libraries
library(dplyr)
library(readr)

# Define the file path for the 2022 dataset
csv_path <- "data/raw/2022/pisa2022_data.csv"

# Load the 2022 dataset
pisa2022_data <- read_csv(csv_path)

# List of well-being variables to exclude for 2022
well_being_vars_2022 <- c(
  "WB150Q01HA", "WB151Q01HA", "WB152Q01HA", "WB153Q01HA", "WB153Q02HA", 
  "WB153Q03HA", "WB153Q04HA", "WB153Q05HA", "WB154Q01HA", "WB154Q02HA", 
  "WB154Q03HA", "WB154Q04HA", "WB154Q05HA", "WB154Q06HA", "WB154Q07HA", 
  "WB154Q08HA", "WB154Q09HA", "WB155Q01HA", "WB155Q02HA", "WB155Q03HA", 
  "WB155Q04HA", "WB155Q05HA", "WB155Q06HA", "WB155Q07HA", "WB155Q08HA", 
  "WB155Q09HA", "WB155Q10HA", "WB156Q01HA", "WB158Q01HA", "WB160Q01HA", 
  "WB161Q01HA", "WB162Q01HA", "WB162Q02HA", "WB162Q03HA", "WB162Q04HA", 
  "WB162Q05HA", "WB162Q06HA", "WB162Q07HA", "WB162Q08HA", "WB162Q09HA", 
  "WB163Q01HA", "WB163Q02HA", "WB163Q03HA", "WB163Q04HA", "WB163Q05HA", 
  "WB163Q06HA", "WB163Q07HA", "WB163Q08HA", "WB164Q01HA", "WB165Q01HA", 
  "WB166Q01HA", "WB166Q02HA", "WB166Q03HA", "WB166Q04HA", "WB167Q01HA", 
  "WB168Q01HA", "WB168Q02HA", "WB168Q03HA", "WB168Q04HA", "WB171Q01HA", 
  "WB171Q02HA", "WB171Q03HA", "WB171Q04HA", "WB172Q01HA", "WB173Q01HA", 
  "WB173Q02HA", "WB173Q03HA", "WB173Q04HA", "WB176Q01HA", "WB177Q01HA", 
  "WB177Q02HA", "WB177Q03HA", "WB177Q04HA", "WB032Q01NA", "WB032Q02NA", 
  "WB031Q01NA", "WB178Q01HA", "WB178Q02HA", "WB178Q03HA", "WB178Q04HA", 
  "WB178Q05HA", "WB178Q06HA", "WB178Q07HA"
)

# Remove well-being variables from the 2022 dataset
pisa2022_cleaned_stage1 <- pisa2022_data %>%
  select(-one_of(well_being_vars_2022))

# Define the function to calculate missing data percentages
calculate_missing_data <- function(data) {
  missing_data_summary <- sapply(data, function(x) sum(is.na(x)) / length(x) * 100)
  return(data.frame(Variable = names(missing_data_summary), 
                    Missing_Percentage = missing_data_summary))
}

# Calculate the percentage of missing data for each variable
missing_data_summary <- calculate_missing_data(pisa2022_cleaned_stage1)

# Identify variables with 100% missing data
high_missing_summary <- missing_data_summary %>%
  filter(Missing_Percentage == 100)

# Remove variables with 100% missing data
pisa2022_cleaned_stage1 <- pisa2022_cleaned_stage1 %>%
  select(-one_of(high_missing_summary$Variable))

# Save the cleaned 2022 dataset
output_path <- "data/private/processed/2022/pisa2022_cleaned_1_initial_data_removal.csv"
write_csv(pisa2022_cleaned_stage1, output_path)

# Create the cleaning log for 2022
if (nrow(high_missing_summary) > 0) {
  cleaning_log <- data.frame(
    Year = rep(2022, nrow(high_missing_summary)),
    Removed_Variable = high_missing_summary$Variable,
    Reason = "100% missing data"
  )
} else {
  # Create an empty cleaning log if no variables were removed
  cleaning_log <- data.frame(
    Year = integer(),
    Removed_Variable = character(),
    Reason = character()
  )
}

# Define the path for saving the cleaning log for 2022
log_path <- "data/private/metadata/2022/stage1_cleaning_log_2022.csv"

# Ensure the directory exists
log_dir <- dirname(log_path)
if (!dir.exists(log_dir)) dir.create(log_dir, recursive = TRUE)

# Save the cleaning log
write_csv(cleaning_log, log_path)

cat("2022 cleaning process completed. Cleaned dataset saved to:", output_path, "\n")
cat("Cleaning log saved to:", log_path, "\n")
