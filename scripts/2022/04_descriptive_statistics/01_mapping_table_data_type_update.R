# --------------------------------------
# PISA 2022 Mapping Table Data Type Update
# --------------------------------------
# Purpose: This script updates the variable data types for the PISA 2022 mapping table by:
# 1. Loading the original mapping table containing variable metadata.
# 2. Excluding variables marked as "Excluded" by explicitly assigning NA to their data types.
# 3. Checking which variables from the mapping table currently exist in the cleaned dataset.
# 4. Programmatically determining the actual data type (NUM or CHAR) of each existing variable in the cleaned dataset.
# 5. Updating the newly created 'cleaned_data_type' column in the mapping table accordingly.
# 6. Exporting the updated mapping table to a CSV file for future reference and analysis.
# --------------------------------------

library(tidyverse)

# Define file paths
mapping_table_path <- "data/private/metadata/2022/pisa2022_variable_mapping_table.csv"
data_path <- "data/private/processed/2022/pisa2022_cleaned_17_final_imputed_data.csv"
output_path <- "data/private/metadata/2022/pisa2022_variable_mapping_table.csv"

# Load mapping table
mapping_table <- read_csv(mapping_table_path, show_col_types = FALSE)

# Load the cleaned dataset
df <- read_csv(data_path, show_col_types = FALSE)

# Update 'cleaned_data_type' in mapping_table programmatically
mapping_table_updated <- mapping_table %>%
  mutate(cleaned_data_type = case_when(
    status == "Excluded" ~ NA_character_,  # Explicitly set Excluded vars to NA
    renamed_variable %in% colnames(df) & map_lgl(renamed_variable, ~ is.numeric(df[[.x]])) ~ "NUM",
    renamed_variable %in% colnames(df) & map_lgl(renamed_variable, ~ !is.numeric(df[[.x]])) ~ "CHAR",
    TRUE ~ NA_character_  # Set to NA if variable not present in df
  ))

# Export the updated mapping table
write_csv(mapping_table_updated, output_path)
