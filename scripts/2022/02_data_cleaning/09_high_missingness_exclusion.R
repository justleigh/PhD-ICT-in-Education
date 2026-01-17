# --------------------------------------
# PISA 2022 Exclusion of High-Missingness Variables
# --------------------------------------
# Purpose:
# - Identify and remove variables with excessive missing data that compromise analytical reliability.
# - Ensure that only variables with sufficient response rates are retained for further analysis.
# - Improve dataset quality by eliminating variables that introduce high levels of uncertainty.
# - Save the cleaned dataset for the next stage of data processing.

# Load necessary libraries
library(readr)
library(dplyr)

# Define file paths
file_input <- "data/private/processed/2022/pisa2022_cleaned_3_variable_selection.csv"
file_output <- "data/private/processed/2022/pisa2022_cleaned_4_high_missingness_exclusion.csv"

# Load the dataset
data <- read_csv(file_input, show_col_types = FALSE)

# Define the list of variables to remove
vars_to_remove <- c(
  "student_body_image",
  "social_conn_parents",
  "life_satisfaction",
  "psychosomatic_symptoms",
  "social_connection",
  "experienced_wellbeing",
  "parental_current_support",
  "parent_math_importance",
  "parent_math_career",
  "parent_involvement",
  "school_quality",
  "school_parent_policies",
  "parent_immigrant_att",
  "parent_career_expect",
  "future_study_work_country_specific",
  "expected_occupation_status"
)

# Remove the specified variables
data_cleaned <- data %>% select(-all_of(vars_to_remove))

# Save the cleaned dataset
write_csv(data_cleaned, file_output)

# Confirmation message
cat("\n✅ Successfully removed", length(vars_to_remove), "variables and saved cleaned dataset to:", file_output, "\n")
