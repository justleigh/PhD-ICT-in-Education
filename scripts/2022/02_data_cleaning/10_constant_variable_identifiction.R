# Load necessary libraries
library(dplyr)
library(readr)
library(tidyr)

# Step 1: Read the cleaned dataset to identify constant variables
pisa_data_cleaned_4 <- read_csv("data/private/processed/2022/pisa2022_cleaned_4_high_missingness_exclusion.csv", show_col_types = FALSE)

# Identify constant variables: check for variables that have only one unique value
constant_vars <- pisa_data_cleaned_4 %>%
  summarise(across(everything(), ~ n_distinct(.) == 1)) %>%
  pivot_longer(cols = everything(), names_to = "variable", values_to = "is_constant") %>%
  filter(is_constant == TRUE) %>%
  pull(variable)

# Step 2: Read the variable mapping table to get additional information
variable_mapping_table <- read_csv("data/private/metadata/2022/pisa2022_variable_mapping_table.csv", show_col_types = FALSE)

# Step 3: Extract relevant information (original_variable_name, renamed_variable, and variable_description) for constant variables
constant_vars_info <- variable_mapping_table %>%
  filter(renamed_variable %in% constant_vars) %>%
  select(original_variable_name, renamed_variable, variable_description)

# Step 4: Create a final table with the constant variables and their corresponding descriptions
constant_variables_table <- constant_vars_info %>%
  mutate(constant_value = sapply(renamed_variable, function(var) unique(pisa_data_cleaned_4[[var]])[1]))  # Extract constant value

# Step 5: Save the table as a CSV file
write_csv(constant_variables_table, "data/private/metadata/2022/constant_variables.csv")

cat("The table of constant variables has been created and saved as 'constant_variables.csv'.\n")
