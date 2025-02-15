# Load necessary libraries
library(dplyr)
library(readr)

# Read in the cleaned dataset
pisa_data_cleaned_4 <- read.csv("data/private/processed/2022/pisa2022_cleaned_4_high_missingness_exclusion.csv")

# Load the variable mapping table that identifies excluded variables
variable_mapping_table <- read.csv("data/private/metadata/2022/pisa2022_variable_mapping_table.csv")

# Identify excluded variables from the mapping table (filter by 'Exclude' in 'status' column)
excluded_variables_from_mapping <- variable_mapping_table %>%
  filter(status == "Excluded") %>%
  select(renamed_variable) %>%  # Updated to the correct column name
  pull()  # Extract the variable names as a vector

# Check which excluded variables exist in the dataset
existing_excluded_vars <- excluded_variables_from_mapping[excluded_variables_from_mapping %in% colnames(pisa_data_cleaned_4)]

# Get the number of excluded variables
num_excluded_variables <- length(existing_excluded_vars)

# Remove the excluded variables that exist in the dataset
pisa_data_cleaned_5 <- pisa_data_cleaned_4 %>%
  select(-one_of(existing_excluded_vars))

# Get the number of remaining variables after exclusion
num_remaining_variables <- ncol(pisa_data_cleaned_5)

# Save the intermediate cleaned dataset (after removing excluded variables) to a new file
write.csv(pisa_data_cleaned_5, "data/private/processed/2022/pisa2022_cleaned_5_logical_exclusion.csv", row.names = FALSE)

# Confirm the removal and number of excluded variables
cat("A total of", num_excluded_variables, "variables have been excluded from the dataset.\n")
cat("The dataset has been saved as 'pisa2022_cleaned_5_logical_exclusion.csv'.\n")
cat("There are", num_remaining_variables, "variables remaining in the dataset after exclusion.\n")
