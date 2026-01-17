# --------------------------------------
# PISA 2022 Imputation of Expected Education Level
# --------------------------------------
# Purpose:
# - Prepare the dataset by replacing invalid values (95, 97, 98, 99) with NA for imputation.
# - Identify relevant predictor variables to improve the accuracy of imputed values.
# - Perform multiple imputation using the Predictive Mean Matching (PMM) method.
# - Ensure transparency by creating a log of imputed students.
# - Compare dataset statistics before and after imputation to verify improvements.
# - Save the final imputed dataset for further analysis.

# Load required libraries
library(tidyverse)
library(mice)

# Define file paths
input_file <- "data/private/processed/2022/pisa2022_cleaned_6_logical_exclusion.csv"
output_file <- "data/private/processed/2022/pisa2022_cleaned_7_imputed_expected_education_level.csv"
imputed_log_file <- "data/private/interim/2022/pisa2022_imputed_expected_education_level.csv"

# Load the cleaned_6 dataset
cleaned_6 <- read_csv(input_file, show_col_types = FALSE)

# Define relevant predictor variables for imputation of `expected_education_level`
predictor_vars <- c(
  "home_books_total", "home_internet", "home_computer", "mother_highest_education", 
  "father_highest_education", "skipped_whole_day", "skipped_classes", "late_for_school", 
  "student_belongs", "teacher_shows_interest_learning", "teacher_concerned", 
  "teacher_friendly", "student_feels_lonely", "handle_stress_well", "remain_calm_under_stress", 
  "digital_learning_school_hours", "digital_learning_before_after_hours", 
  "digital_learning_weekend_hours", "parent_discuss_progress", 
  "parent_discuss_education_importance", "parent_encourage_grades", 
  "total_homework_time_all_subjects", "math_attention_to_teacher", 
  "math_effort_assignments", "family_social_status_now", "family_social_status_future"
)

# Step 1: Replace invalid values (95, 97, 98, 99) with NA for imputation
cleaned_6_prepared <- cleaned_6 %>%
  mutate(across(all_of(predictor_vars), ~ ifelse(. %in% c(95, 97, 98, 99), NA, .))) %>%
  mutate(expected_education_level = ifelse(expected_education_level %in% c(95, 97, 98, 99), NA, expected_education_level))

# Debugging Outputs - BEFORE Imputation
cat("\nBEFORE Imputation:\n")
cat("Number of rows:", nrow(cleaned_6_prepared), "\n")
cat("Number of variables:", ncol(cleaned_6_prepared), "\n")
cat("Total NA values in dataset:", sum(is.na(cleaned_6_prepared)), "\n")
cat("Total NA values in expected_education_level:", sum(is.na(cleaned_6_prepared$expected_education_level)), "\n")

# Step 2: Perform multiple imputation including relevant predictors with missing values
mice_data <- mice(
  cleaned_6_prepared %>% select(all_of(predictor_vars), expected_education_level), 
  m = 5, method = "pmm", seed = 123
)

# Step 3: Extract only the imputed `expected_education_level`
imputed_values <- complete(mice_data)[["expected_education_level"]]

# Step 4: Restore original values for all other variables except `expected_education_level`
cleaned_7 <- cleaned_6 %>%
  mutate(expected_education_level = imputed_values)

# Debugging Outputs - AFTER Imputation
cat("\nAFTER Imputation:\n")
cat("Number of rows:", nrow(cleaned_7), "\n")
cat("Number of variables:", ncol(cleaned_7), "\n")
cat("Total NA values in dataset:", sum(is.na(cleaned_7)), "\n")
cat("Total NA values in expected_education_level:", sum(is.na(cleaned_7$expected_education_level)), "\n")

# Step 5: Save the imputed dataset
write_csv(cleaned_7, output_file)

# Step 6: Create a log of imputed students for transparency
imputed_students <- cleaned_6 %>%
  filter(is.na(expected_education_level) | expected_education_level %in% c(95, 97, 98, 99)) %>%
  select(student_id, expected_education_level_before = expected_education_level) %>%
  mutate(expected_education_level_after = cleaned_7$expected_education_level[match(student_id, cleaned_6$student_id)])

# Save the log of imputed students
write_csv(imputed_students, imputed_log_file)

cat("\nImputation complete. Cleaned dataset and imputation log saved.\n")

# Compare total NA values before and after imputation
na_comparison <- tibble(
  Dataset = c("cleaned_6", "cleaned_7"),
  Total_NA = c(sum(is.na(cleaned_6)), sum(is.na(cleaned_7))),
  NA_in_expected_education_level = c(
    sum(is.na(cleaned_5$expected_education_level)), 
    sum(is.na(cleaned_6$expected_education_level))
  )
)

print(na_comparison)
