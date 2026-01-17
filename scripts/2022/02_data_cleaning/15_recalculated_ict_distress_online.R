# --------------------------------------
# PISA 2022 ICT Distress Online Imputation and Debugging
# --------------------------------------
# Purpose:
# - Identify cases where `ict_distress_online` is missing and should be imputed.
# - Use related variables (`upset_inappropriate_content`, `upset_discriminatory_content`, 
#   `upset_offensive_messages`, `upset_info_public_without_consent`) to determine valid imputations.
# - Ensure imputed values align with response patterns while preserving data integrity.
# - Create a verification log before modifying the dataset to maintain transparency.
# - Compare dataset statistics before and after imputation to verify changes.
# - Save the updated dataset and debugging logs for reproducibility.

# Load required libraries
library(tidyverse)

# Step 1: Load the dataset from cleaned_7
original_data <- read_csv("data/private/processed/2022/pisa2022_cleaned_7_imputed_expected_education_level.csv")

# Step 2: Identify cases where `ict_distress_online` should be imputed
data <- original_data %>%
  mutate(
    valid_responses = rowSums(!is.na(select(., upset_inappropriate_content, 
        upset_discriminatory_content, 
        upset_offensive_messages, 
        upset_info_public_without_consent)) & 
    select(., upset_inappropriate_content, 
        upset_discriminatory_content, 
        upset_offensive_messages, 
        upset_info_public_without_consent) != 98 & 
    select(., upset_inappropriate_content, 
        upset_discriminatory_content, 
        upset_offensive_messages, 
        upset_info_public_without_consent) != 99, na.rm = TRUE),
    
    # Identify rows that meet the imputation condition
    recalculated_flag = valid_responses >= 3 &
      upset_inappropriate_content == 1 &
      upset_discriminatory_content == 1 &
      upset_offensive_messages == 1 &
      upset_info_public_without_consent == 1 &
      is.na(ict_distress_online)
  )

# Step 3: Create a verification log **before modifying the dataset**
verification_log <- data %>%
  filter(recalculated_flag) %>%
  select(student_id, 
         upset_inappropriate_content, upset_discriminatory_content, 
         upset_offensive_messages, upset_info_public_without_consent, 
         ict_distress_online) %>%
  mutate(ict_distress_online_new = 0)  # New recalculated value

# Step 4: Impute `ict_distress_online` where conditions are met
data <- data %>%
  mutate(ict_distress_online = ifelse(recalculated_flag, 0, ict_distress_online)) %>%
  select(-valid_responses, -recalculated_flag)  # Remove helper columns

# Step 5: Save the updated dataset
write_csv(data, "data/private/processed/2022/pisa2022_cleaned_8_recalculated_ict_distress_online.csv")

# Step 6: Save the verification log
write_csv(verification_log, "data/private/interim/2022/pisa2022_verification_ict_distress_online.csv")

# Step 7: Debugging Comparison of cleaned_7 vs cleaned_8

# Function to compute dataset statistics
count_debug_stats <- function(df) {
  list(
    rows = nrow(df),
    variables = ncol(df),
    na_count = sum(is.na(df)),  # Total NAs
    count_98 = sum(df == 98, na.rm = TRUE),  # Count of 98
    count_99 = sum(df == 99, na.rm = TRUE)   # Count of 99
  )
}

# Compute statistics before and after imputation
stats_cleaned_7 <- count_debug_stats(original_data)
stats_cleaned_8 <- count_debug_stats(data)

# Display comparison
cat("\n🔹 Debugging Comparison (Before vs After Imputation):\n")
cat("\n📌 Cleaned_7 Dataset (Before Imputation):\n")
cat(" - Rows:", stats_cleaned_7$rows, "\n")
cat(" - Variables:", stats_cleaned_7$variables, "\n")
cat(" - NA Count:", stats_cleaned_7$na_count, "\n")
cat(" - 98 Count:", stats_cleaned_7$count_98, "\n")
cat(" - 99 Count:", stats_cleaned_7$count_99, "\n\n")

cat("\n📌 Cleaned_8 Dataset (After Imputation):\n")
cat(" - Rows:", stats_cleaned_8$rows, "\n")
cat(" - Variables:", stats_cleaned_8$variables, "\n")
cat(" - NA Count:", stats_cleaned_8$na_count, "\n")
cat(" - 98 Count:", stats_cleaned_8$count_98, "\n")
cat(" - 99 Count:", stats_cleaned_8$count_99, "\n\n")

# Step 8: Double-check dataset structure
summary(data$ict_distress_online)
