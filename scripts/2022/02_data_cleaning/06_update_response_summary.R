# Load necessary libraries
library(dplyr)
library(readr)

# File paths
response_summary_path <- "data/private/metadata/2022/pisa2022_questionnaire_response_summary_for_missingness_analysis.csv"
variable_mapping_path <- "data/private/metadata/2022/pisa2022_variable_mapping_table.csv"

# Read the files
response_summary <- read_csv(response_summary_path)
variable_mapping <- read_csv(variable_mapping_path)

# Ensure all relevant columns in both dataframes are character
response_summary <- response_summary %>%
  mutate(
    inclusion_status = as.character(inclusion_status),
    inclusion_priority = as.character(inclusion_priority),
    reason_for_decision = as.character(reason_for_decision)
  )

variable_mapping <- variable_mapping %>%
  mutate(
    status = as.character(status),
    status_priority = as.character(status_priority),
    status_reason = as.character(status_reason)
  )

# Join data from variable_mapping into response_summary based on original_variable_name
response_summary_updated <- response_summary %>%
  left_join(
    variable_mapping %>%
      select(
        original_variable_name, 
        inclusion_status = status, 
        inclusion_priority = status_priority, 
        reason_for_decision = status_reason
      ),
    by = "original_variable_name"
  ) %>%
  # Update columns only where there is a match, keep existing values otherwise
  mutate(
    inclusion_status = ifelse(is.na(inclusion_status.y), inclusion_status.x, inclusion_status.y),
    inclusion_priority = ifelse(is.na(inclusion_priority.y), inclusion_priority.x, inclusion_priority.y),
    reason_for_decision = ifelse(is.na(reason_for_decision.y), reason_for_decision.x, reason_for_decision.y)
  ) %>%
  # Remove temporary columns created during the join
  select(-ends_with(".x"), -ends_with(".y"))

# Replace NA values with blanks in all columns except 'value' and 'Label'
response_summary_updated <- response_summary_updated %>%
  mutate(across(
    .cols = -c(value, Label), # Exclude 'value' and 'Label' columns
    .fns = ~ ifelse(is.na(.), "", .)
  ))

# Save the updated response summary back to the CSV
write_csv(response_summary_updated, response_summary_path)

cat("Data successfully updated: NA values replaced with blanks in all columns except 'value' and 'Label', and inclusion_status, inclusion_priority, and reason_for_decision updated.")
