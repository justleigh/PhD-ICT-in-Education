# Load necessary libraries
library(dplyr)
library(readr)

# File paths for variable mapping table and questionnaire response summary
variable_mapping_path <- "data/private/metadata/2022/pisa2022_variable_mapping_table.csv"
response_summary_path <- "data/private/metadata/2022/pisa2022_questionnaire_response_summary_for_missingness_analysis.csv"

# Read the files
variable_mapping <- read_csv(variable_mapping_path, show_col_types = FALSE)
response_summary <- read_csv(response_summary_path, show_col_types = FALSE)

# Define constant variables to be excluded (non-informative for analysis)
constant_vars_to_remove <- c(
  "ict_questionnaire_flag", "well_being_flag", "parent_questionnaire_flag", "teacher_questionnaire_flag", "uh_questionnaire_flag",
  "mother_qualification_4", "father_qualification_4", "expected_complete_qualification_ISCED4",
  "perseverance_agreement", "cooperation_agreement", "empathy_agreement",
  "assertiveness_agreement", "stress_resistance_agreement", "math_self_efficacy",
  "math_concept_familiarity", "math_anxiety", "ict_enquiry_learning",
  "ict_support_feedback", "ict_outside_class", "math_isc_lvl5_degree_part",
  "digital_device_policies", "diversity_multicultural_views"
)

# Define constant metadata variables to be retained (essential for reference)
constant_vars_to_keep <- c(
  "country_code", "country_id", "assessment_cycle", "national_center_code",
  "sampling_stratum", "subnational_region", "oecd_member", "administration_mode"
)

# Update the variable mapping table for constant variables
variable_mapping_updated <- variable_mapping %>%
  mutate(
    status = case_when(
      renamed_variable %in% constant_vars_to_remove ~ "Excluded",
      renamed_variable %in% constant_vars_to_keep ~ "Included",
      TRUE ~ status
    ),
    status_priority = case_when(
      renamed_variable %in% constant_vars_to_remove ~ "Low",
      renamed_variable %in% constant_vars_to_keep ~ "High",
      TRUE ~ status_priority
    ),
    status_reason = case_when(
      renamed_variable %in% constant_vars_to_remove ~ "Constant variable with no analytical value",
      renamed_variable %in% constant_vars_to_keep ~ "Metadata variable retained for reference",
      TRUE ~ status_reason
    )
  )

# Save the updated variable mapping table
write_csv(variable_mapping_updated, variable_mapping_path)

# Update the questionnaire response summary for constant variables
response_summary_updated <- response_summary %>%
  mutate(
    inclusion_status = case_when(
      renamed_variable %in% constant_vars_to_remove ~ "Excluded",
      renamed_variable %in% constant_vars_to_keep ~ "Included",
      TRUE ~ inclusion_status
    ),
    inclusion_priority = case_when(
      renamed_variable %in% constant_vars_to_remove ~ "Low",
      renamed_variable %in% constant_vars_to_keep ~ "High",
      TRUE ~ inclusion_priority
    ),
    reason_for_decision = case_when(
      renamed_variable %in% constant_vars_to_remove ~ "Constant variable with no analytical value",
      renamed_variable %in% constant_vars_to_keep ~ "Metadata variable retained for reference",
      TRUE ~ reason_for_decision
    )
  )

# Save the updated questionnaire response summary
write_csv(response_summary_updated, response_summary_path)

cat("\n✅ The variable mapping table and questionnaire response summary have been successfully updated.")
