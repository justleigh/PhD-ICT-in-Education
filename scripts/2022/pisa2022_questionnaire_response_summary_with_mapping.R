# Load required libraries
library(dplyr)
library(tidyr)
library(readr)

# Load the cleaned Stage 1 dataset
data <- read.csv("data//private/processed/2022/pisa2022_cleaned_1_initial_data_removal.csv")

# Load the pisa2022_variable_mapping_table
mapping_table <- read.csv("data/private/metadata/2022/pisa2022_variable_mapping_table.csv")

# Ensure column names are aligned in the mapping table
colnames(mapping_table) <- tolower(colnames(mapping_table)) # Standardize to lowercase

# Define variables to include and exclude
include_vars <- grep("^(ST|IC|SC)", names(data), value = TRUE)
exclude_vars <- c(
  "STRATUM", "STUDYHMW", "SCHRISK", "STRESAGR", "SCHSUST", 
  "ICTRES", "ICTSCH", "ICTAVSCH", "ICTHOME", "ICTAVHOM", 
  "ICTQUAL", "ICTSUBJ", "ICTENQ", "ICTFEED", "ICTOUT", 
  "ICTWKDY", "ICTWKEND", "ICTREG", "ICTINFO", "ICTDISTR", 
  "ICTEFFIC", "STUBMI", "SCHLTYPE", "SCHSIZE", "STRATIO", 
  "SCHSEL", "SCHAUTO", "STAFFSHORT", "STUBEHA", "STDTEST", 
  "SCSUPRTED", "SCSUPRT", "SCPREPBP", "SCPREPAP"
)

# Filter variables to include and exclude
vars_to_include <- setdiff(include_vars, exclude_vars)

# Select only relevant columns, maintaining the original order
data_filtered <- data %>% select(all_of(vars_to_include))

# Create the response summary
response_summary <- data_filtered %>%
  pivot_longer(cols = everything(), names_to = "variable", values_to = "value") %>%
  group_by(variable, value) %>%
  summarise(frequency = n(), .groups = "drop") %>%
  group_by(variable) %>%
  mutate(percentage = round((frequency / sum(frequency)) * 100, 2)) %>%
  ungroup()

# Reorder the response summary based on the original dataset variable order
variable_order <- names(data_filtered)
response_summary <- response_summary %>%
  mutate(variable = factor(variable, levels = variable_order)) %>%
  arrange(variable, value)

# Adjust the formatting to show the variable name only once per group
response_summary <- response_summary %>%
  group_by(variable) %>%
  mutate(variable = if_else(row_number() == 1, as.character(variable), "")) %>%
  ungroup()

# Join the response summary with the mapping table
merged_data <- response_summary %>%
  left_join(
    mapping_table %>% select(original_variable_name, renamed_variable, variable_description),
    by = c("variable" = "original_variable_name")
  )

# Ensure columns are blank for duplicate rows within a variable
merged_data <- merged_data %>%
  group_by(variable) %>%
  mutate(
    original_variable_name = ifelse(row_number() == 1, variable, ""),
    renamed_variable = ifelse(row_number() == 1, renamed_variable, ""),
    variable_description = ifelse(row_number() == 1, variable_description, "")
  ) %>%
  ungroup()

# Reorder columns for output
merged_data <- merged_data %>%
  select(variable, original_variable_name, renamed_variable, variable_description, value, frequency, percentage)

# Save the final merged table
# The pisa2022_questionnaire_response_summary_with_mapping.csv is a proprietary 
# file stored in the private folder for intellectual property protection.
# This script references it but does not expose its content.
write.csv(
  merged_data,
  "data/private/metadata/2022/pisa2022_questionnaire_response_summary_with_mapping.csv",
  row.names = FALSE
)

cat("Complete summary table saved to: data/private/metadata/2022/pisa2022_questionnaire_response_summary_with_mapping.csv\n")
