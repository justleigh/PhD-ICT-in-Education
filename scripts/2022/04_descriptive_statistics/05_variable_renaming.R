# ------------------------------------------------------------
# Script: Prefix-Based Variable Renaming with RDS/CSV Outputs
# ------------------------------------------------------------
# This script systematically renames variables in the PISA 2022 dataset 
# to include standardized prefixes that indicate the source of each item:
#   - st_   → Student Questionnaire
#   - ic_   → ICT Questionnaire
#   - sc_   → School Questionnaire
#   - stdv_ → Student-Derived Variable 
#   - icdv_ → ICT-Derived Variable 
#   - scdv_ → School-Derived Variable
#
# This standardization improves traceability, reproducibility, and 
# clarity across all downstream scripts including cleaning, analysis, 
# and modeling workflows.
#
# Output:
# - Cleaned dataset with renamed variables saved to: 
#   data/private/processed/2022/pisa2022_cleaned_18_prefixed_variable_names.csv
#
# Notes:
# - This script should be run immediately after the initial cleaning
#   and imputation steps (i.e., using pisa2022_cleaned_17_final_imputed_data.csv).
# ------------------------------------------------------------

# 📦 Load Required Libraries
library(dplyr)
library(readr)
library(stringr)

# 📥 Load Final Cleaned Imputed Dataset (.rds)
input_rds <- "data/private/processed/2022/pisa2022_cleaned_17_final_imputed_data.rds"
df <- readRDS(input_rds)

# 🔍 Debugging: Store dimensions before renaming
original_nrow <- nrow(df)
original_ncol <- ncol(df)
original_names <- names(df)

cat("🔍 Loaded RDS with", original_nrow, "rows and", original_ncol, "columns.\n")

# Exclude the following flag variables from prefixing
flag_vars <- c(
  "perception_straight_line_flag",
  "feeling_straight_line_flag",
  "persistence_straight_line_flag",
  "math_class_periods_flag",
  "total_class_periods_flag"
)

# Get actual column names for each block
st_block <- names(df)[which(names(df) == "student_grade_level"):which(names(df) == "effort_accurate_pisa")]
ic_block <- names(df)[which(names(df) == "school_use_desktop_laptop"):which(names(df) == "can_represent_solution_steps")]
stdv_block <- names(df)[which(names(df) == "test_effort_actual"):which(names(df) == "escs_index")]
icdv_block <- names(df)[which(names(df) == "ict_at_school"):which(names(df) == "ict_self_efficacy")]
sc_block <- names(df)[which(names(df) == "community_type"):which(names(df) == "preparedness_remote_instruction")]
scdv_block <- names(df)[which(names(df) == "school_type_derived"):which(names(df) == "digital_learning_preparedness")]

# Remove flagged variables from st_block
st_block <- setdiff(st_block, flag_vars)

# Apply renaming
df_renamed <- df |>
  rename_with(~ paste0("st_", .x), .cols = all_of(st_block)) |>
  rename_with(~ paste0("ic_", .x), .cols = all_of(ic_block)) |>
  rename_with(~ paste0("stdv_", .x), .cols = all_of(stdv_block)) |>
  rename_with(~ paste0("icdv_", .x), .cols = all_of(icdv_block)) |>
  rename_with(~ paste0("sc_", .x), .cols = all_of(sc_block)) |>
  rename_with(~ paste0("scdv_", .x), .cols = all_of(scdv_block))

# 🧪 Debugging: Check for data integrity
if (nrow(df_renamed) != original_nrow || ncol(df_renamed) != original_ncol) {
  stop("❌ Data dimensions changed after renaming. Aborting script.")
} else {
  cat("✅ Data dimensions unchanged after renaming.\n")
}

# 🪪 Preview renamed columns
cat("🔧 Sample of renamed variable names:\n")
print(head(names(df_renamed), 10))

# 💾 Save Renamed Dataset to CSV and RDS
output_csv <- "data/private/processed/2022/pisa2022_cleaned_18_prefixed_variable_names.csv"
output_rds <- "data/private/processed/2022/pisa2022_cleaned_18_prefixed_variable_names.rds"

write_csv(df_renamed, output_csv)
saveRDS(df_renamed, output_rds)

# ✅ Final Confirmation
cat("🎉 Renamed dataset saved as:\n", output_csv, "\n", output_rds, "\n")