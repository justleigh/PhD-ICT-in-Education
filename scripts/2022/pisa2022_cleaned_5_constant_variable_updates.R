# Load necessary libraries
library(dplyr)
library(readr)

# Read the dataset and metadata tables
pisa_data <- read_csv("data/private/processed/2022/pisa2022_cleaned_4_high_missingness_exclusion.csv", show_col_types = FALSE)
variable_mapping_table <- read_csv("data/private/metadata/2022/pisa2022_variable_mapping_table.csv", show_col_types = FALSE)
response_summary <- read_csv("data/private/metadata/2022/pisa2022_questionnaire_response_summary_for_missingness_analysis.csv", show_col_types = FALSE)

# Define constant variables to be removed (original names)
constant_variables <- c(
  "CNT", "NatCen", "OECD", "Option_ICTQ", "Option_WBQ", "Option_PQ", "Option_TQ", "Option_UH",
  "ST006Q05JA", "ST008Q05JA", "ST327Q04JA", "PERSEVAGR", "COOPAGR", "EMPATAGR", "ASSERAGR", 
  "STRESAGR", "MATHEFF", "FAMCON", "ANXMAT", "ICTENQ", "ICTFEED", "ICTOUT", "SC182Q10JA02", 
  "DIGDVPOL", "DMCVIEWS"
)

# Match renamed column names from the variable mapping table
matched_columns <- variable_mapping_table %>%
  filter(original_variable_name %in% constant_variables) %>%
  select(renamed_variable) %>%
  pull()

# Remove the identified constant variables from the dataset
pisa_data_cleaned <- pisa_data %>%
  select(-all_of(matched_columns))

# Save the cleaned dataset
write_csv(pisa_data_cleaned, "data/private/processed/2022/pisa2022_cleaned_5_select_constant_variables_removed.csv")

# Update the variable mapping table
variable_mapping_table_updated <- variable_mapping_table %>%
  mutate(
    status = ifelse(original_variable_name %in% constant_variables, "Excluded", status),
    status_priority = ifelse(original_variable_name %in% constant_variables, "Low", status_priority),
    status_reason = ifelse(original_variable_name %in% constant_variables, "Constant variable", status_reason)
  )

# Save the updated variable mapping table
write_csv(variable_mapping_table_updated, "data/private/metadata/2022/pisa2022_variable_mapping_table.csv")

# Update the response summary table
response_summary_updated <- response_summary %>%
  mutate(
    inclusion_status = ifelse(original_variable_name %in% constant_variables, "Excluded", inclusion_status),
    inclusion_priority = ifelse(original_variable_name %in% constant_variables, "Low", inclusion_priority),
    reason_for_decision = ifelse(original_variable_name %in% constant_variables, "Constant variable", reason_for_decision)
  )

# Save the updated response summary table
write_csv(response_summary_updated, "data/private/metadata/2022/pisa2022_questionnaire_response_summary_for_missingness_analysis.csv")

# Print confirmation message
cat("Constant variables removed, and metadata tables updated successfully.\n")
