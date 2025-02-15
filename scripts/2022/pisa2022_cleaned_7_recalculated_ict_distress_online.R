# Load required libraries
library(tidyverse)

# Step 1: Load the dataset from cleaned_6
original_data <- read_csv("data/private/processed/2022/pisa2022_cleaned_6_imputed_expected_education_level.csv")

# Step 2: Rename `ict_distress_online` to preserve its original values
recalculated_data <- original_data %>%
  rename(ict_distress_online_old = ict_distress_online)  # Keep original values unchanged

# Step 3: Create `ict_distress_online_recalculated` (Initial Copy of Old Values)
recalculated_data <- recalculated_data %>%
  mutate(ict_distress_online_recalculated = ict_distress_online_old)

# Step 4: Modify only the students who entered `1,1,1,1`
recalculated_data <- recalculated_data %>%
  mutate(
    ict_distress_online_recalculated = case_when(
      # If all four input variables are `1` AND `ict_distress_online_old` is NA, set to 0
      upset_inappropriate_content == 1 & 
        upset_discriminatory_content == 1 & 
        upset_offensive_messages == 1 & 
        upset_info_public_without_consent == 1 & 
        is.na(ict_distress_online_old) ~ 0,
      
      # Otherwise, keep the existing value
      TRUE ~ ict_distress_online_recalculated
    )
  )

# **Final Fix: Replace Remaining NA Values in `ict_distress_online_recalculated` with 0**
recalculated_data <- recalculated_data %>%
  mutate(ict_distress_online_recalculated = replace_na(ict_distress_online_recalculated, 0))

# Step 5: Ensure `ict_distress_online_recalculated` is placed immediately after `ict_distress_online_old`
final_data <- recalculated_data %>%
  relocate(ict_distress_online_recalculated, .after = ict_distress_online_old)  # Ensures correct placement

# Step 6: Ensure directories exist before saving files
processed_path <- "data/private/processed/2022"
interim_path <- "data/private/interim/2022"

if (!dir.exists(processed_path)) {
  dir.create(processed_path, recursive = TRUE)
  cat("Created missing directory:", processed_path, "\n")
}

if (!dir.exists(interim_path)) {
  dir.create(interim_path, recursive = TRUE)
  cat("Created missing directory:", interim_path, "\n")
}

# Step 7: Save the complete recalculated dataset as cleaned_7
write_csv(final_data, "data/private/processed/2022/pisa2022_cleaned_7_recalculated_ict_distress_online.csv")

# Step 8: Save the verification log (to compare original vs recalculated distress values)
verification_log <- recalculated_data %>%
  select(student_id, ict_distress_online_old, ict_distress_online_recalculated)

write_csv(verification_log, "data/private/interim/2022/pisa2022_verification_ict_distress_online.csv")

# Step 9: Verification Outputs for Comparison

# Load cleaned_7 dataset for verification
cleaned_7_data <- read_csv("data/private/processed/2022/pisa2022_cleaned_7_recalculated_ict_distress_online.csv")

# Function to count NA and 99 values in the dataset
count_na_99 <- function(data) {
  list(
    rows = nrow(data),
    variables = ncol(data),
    na_count = sum(is.na(data)),  # Count all missing values
    count_99 = sum(data == 99, na.rm = TRUE)  # Count all occurrences of 99
  )
}

# Get statistics for cleaned_6 (original) and cleaned_7 (updated)
stats_cleaned_6 <- count_na_99(original_data)
stats_cleaned_7 <- count_na_99(cleaned_7_data)

# Display comparison
cat("\nVerification Outputs:\n")
cat("Cleaned_6 Dataset (Original):\n")
cat(" - Rows:", stats_cleaned_6$rows, "\n")
cat(" - Variables:", stats_cleaned_6$variables, "\n")
cat(" - NA Count:", stats_cleaned_6$na_count, "\n")
cat(" - 99 Count:", stats_cleaned_6$count_99, "\n\n")

cat("Cleaned_7 Dataset (Updated):\n")
cat(" - Rows:", stats_cleaned_7$rows, "\n")
cat(" - Variables:", stats_cleaned_7$variables, "\n")
cat(" - NA Count:", stats_cleaned_7$na_count, "\n")
cat(" - 99 Count:", stats_cleaned_7$count_99, "\n\n")

# Double-check dataset structure
summary(cleaned_7_data$ict_distress_online_recalculated)
