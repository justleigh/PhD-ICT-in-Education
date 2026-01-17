# --------------------------------------
# PISA 2022 Final Variable Selection, Data Cleaning, and Debugging
# --------------------------------------
# Purpose:
# - Remove excluded variables based on statistical screening.
# - Clean up factor labels for ISCED variables by removing parentheses
# - Ensure data integrity before analysis.
# - Compare raw and final cleaned datasets for missing values and other key statistics.
# - Confirm that 95 and 97 were correctly reclassified into "valid_skip" and "random_skip."
# - Identify variables still containing 95, 97, 98, and 99 for verification.

# Load necessary libraries
library(dplyr)
library(readr)

# CSV and RDS helper Function
save_cleaned <- function(df, csv_path) {
  write_csv(df, csv_path)
  rds_path <- str_replace(csv_path, ".csv$", ".rds")
  saveRDS(df, rds_path)
  cat("✅ Data saved as CSV:", csv_path, "\n")
  cat("✅ Data saved as RDS:", rds_path, "\n")
}

# File paths
mapping_table_path <- "data/private/metadata/2022/pisa2022_variable_mapping_table.csv"
raw_data_path <- "data/raw/2022/pisa2022_data.csv"
input_data_path <- "data/private/processed/2022/pisa2022_cleaned_15_flagging_procedures.rds"
output_data_path <- "data/private/processed/2022/pisa2022_cleaned_16_final_cleaned_data.csv"
debugging_output_path <- "data/private/metadata/2022/pisa2022_cleaned_16_debugging_analysis.csv"
debugging_log_path <- "data/private/metadata/2022/pisa2022_cleaned_16_debugging_log.csv"

# Step 1: Load the variable mapping table
mapping_table <- read_csv(mapping_table_path, show_col_types = FALSE)

# Step 2: Extract variables marked as "Excluded" in the "status" column
excluded_vars <- mapping_table %>%
  filter(status == "Excluded") %>%
  pull(renamed_variable)  

# Step 3: Load the datasets
raw_data <- read_csv(raw_data_path, show_col_types = FALSE)
cleaned_data <- readRDS(input_data_path)

# Step 4: Identify which excluded variables are still present in the dataset
existing_excluded_vars <- intersect(excluded_vars, colnames(cleaned_data))

# Step 5: Remove only those variables that still exist in the dataset
cleaned_data_final <- cleaned_data %>%
  select(-all_of(existing_excluded_vars))

# Step 6: Clean up factor labels for ISCED variables by removing parentheses
cleaned_data_final <- cleaned_data_final %>%
  mutate(across(
    c(mother_education_level, father_education_level, parent_highest_edu_lvl, expected_education_level),
    ~ if (is.factor(.)) {
      forcats::fct_relabel(., function(x) {
        x %>%
          stringr::str_replace_all("[()]", "") %>%   # remove parentheses
          stringr::str_squish()                      # clean up spacing
      })
    } else {
      .
    }
  ))

# Step 7: Save the final cleaned dataset
save_cleaned(cleaned_data_final, output_data_path)

# Print summary
cat("Final cleaned dataset saved as:", output_data_path, "\n")
cat("Total variables removed:", length(existing_excluded_vars), "\n")
cat("Remaining variables:", ncol(cleaned_data_final), "\n")

# Step 8: Final Debugging Table (Raw vs Cleaned)

# Define the missing value categories and their labels in the required order
missing_values <- c(95, "valid_skip", 97, "random_skip", 98, 99)
value_labels <- c("95", "Valid Skip", "97", "Random Skip", "98", "99", "NA")

# Compute counts for raw and cleaned data (excluding NA)
raw_counts <- sapply(missing_values, function(val) sum(raw_data == val, na.rm = TRUE))
cleaned_counts <- sapply(missing_values, function(val) sum(cleaned_data_final == val, na.rm = TRUE))

# Count NA values separately
raw_na_count <- sum(is.na(raw_data))
cleaned_na_count <- sum(is.na(cleaned_data_final))

# Append NA counts to the result
raw_counts <- c(raw_counts, raw_na_count)
cleaned_counts <- c(cleaned_counts, cleaned_na_count)

# Create debugging summary table (raw counts only)
debugging_summary <- tibble(
  `Category/Value` = c("Total rows", "Total variables", value_labels),
  `Raw data` = c(nrow(raw_data), ncol(raw_data), raw_counts),
  `Cleaned data` = c(nrow(cleaned_data_final), ncol(cleaned_data_final), cleaned_counts)
)

# Save debugging summary to CSV
write_csv(debugging_summary, debugging_output_path)

# Print confirmation message
cat("Debugging table comparing raw and cleaned data saved to:", debugging_output_path, "\n")

# Step 9: Generate Debugging Log for Remaining 95, 97, 98, 99 Values (Two-Tiered Format with 4 Columns)

# Function to identify variables still containing specific values
identify_remaining_values <- function(df, value) {
  df %>%
    summarise(across(everything(), ~ sum(. == value, na.rm = TRUE))) %>%
    pivot_longer(cols = everything(), names_to = "Variable", values_to = "Count") %>%
    filter(Count > 0)  # Keep only variables with occurrences of the value
}

# Identify variables with remaining problematic values
remaining_95 <- identify_remaining_values(cleaned_data_final, 95)
remaining_97 <- identify_remaining_values(cleaned_data_final, 97)
remaining_98 <- identify_remaining_values(cleaned_data_final, 98)
remaining_99 <- identify_remaining_values(cleaned_data_final, 99)

# Ensure all lists are of equal length to avoid tibble column size mismatches
max_length <- max(nrow(remaining_95), nrow(remaining_97), nrow(remaining_98), nrow(remaining_99))

pad_vector <- function(df, max_length) {
  if (nrow(df) < max_length) {
    df <- bind_rows(df, tibble(Variable = rep(NA, max_length - nrow(df)), Count = rep(NA, max_length - nrow(df))))
  }
  return(df)
}

remaining_95 <- pad_vector(remaining_95, max_length)
remaining_97 <- pad_vector(remaining_97, max_length)
remaining_98 <- pad_vector(remaining_98, max_length)
remaining_99 <- pad_vector(remaining_99, max_length)

# **Manually Stacking Data for a 4-Column Layout**
tier_1 <- tibble(
  `Value` = "95",
  `Variable` = remaining_95$Variable,
  `Count` = remaining_95$Count,
  `Value_2` = "97",
  `Variable_2` = remaining_97$Variable,
  `Count_2` = remaining_97$Count
)

tier_2 <- tibble(
  `Value` = "98",
  `Variable` = remaining_98$Variable,
  `Count` = remaining_98$Count,
  `Value_2` = "99",
  `Variable_2` = remaining_99$Variable,
  `Count_2` = remaining_99$Count
)

# **Final Two-Tiered Table with 4 Columns**
debugging_log_tiered <- bind_rows(tier_1, tier_2)

# Save debugging log to CSV
write_csv(debugging_log_tiered, debugging_log_path)

# Print confirmation message
cat("Debugging log saved to:", debugging_log_path, "\n")
