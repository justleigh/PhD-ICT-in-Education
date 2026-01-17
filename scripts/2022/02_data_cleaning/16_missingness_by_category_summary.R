# --------------------------------------
# PISA 2022 Special Code Frequency Summary
# --------------------------------------
# Purpose: This script summarizes the frequency of special codes (95, 97, 98, 99, NA) 
# in the cleaned PISA 2022 dataset by:
# 1. Dynamically defining variable categories using start and end markers.
# 2. Identifying WLEs and Plausible Values (PVs) based on naming patterns.
# 3. Counting the occurrence of each special code within each variable category.
# 4. Printing and exporting a summary table for further review or diagnostics.
# --------------------------------------

# Load necessary libraries
library(dplyr)

# Define file path
data_path <- "data/private/processed/2022/pisa2022_cleaned_8_recalculated_ict_distress_online.csv"

# Load dataset
df <- read.csv(data_path, stringsAsFactors = FALSE)

# -----------------------------------------------
# 🔎 Helper function: Select variables between two points
select_vars_between <- function(start_var, end_var, var_names) {
  start_pos <- which(var_names == start_var)
  end_pos <- which(var_names == end_var)
  if (length(start_pos) == 1 && length(end_pos) == 1) {
    return(var_names[start_pos:end_pos])
  } else {
    stop("Start or end variable not found!")
  }
}

# -----------------------------------------------
# 🗂️ Define variable categories dynamically
var_names <- names(df)

variable_categories <- list(
  # Example groups based on your logic:
  
  student_questionnaire_vars = select_vars_between("student_grade_level", "effort_accurate_pisa", var_names),
  
  ict_questionnaire_vars = select_vars_between("school_use_desktop_laptop", "can_represent_solution_steps", var_names),
  
  student_derived_vars = select_vars_between("test_effort_actual", "escs_index", var_names),
  
  ict_derived_vars = select_vars_between("ict_at_school", "ict_self_efficacy", var_names),
  
  school_questionnaire_vars = select_vars_between("community_type", "encourage_pisa_effort", var_names),
  
  school_derived_vars = select_vars_between("school_type_derived", "digital_learning_preparedness", var_names)
)

# -----------------------------------------------
# Function to filter only existing variables in df
filter_existing_vars <- function(var_list, df) {
  intersect(var_list, names(df))
}

# Identify WLEs and Plausible Values (PVs) dynamically
wle_vars <- grep("^W_", colnames(df), value = TRUE)
pv_vars <- grep("^PV", colnames(df), value = TRUE)

# Function to count occurrences of 95, 97, 98, 99, and NA values in a variable category
count_special_codes <- function(variable_list, df) {
  if (length(variable_list) == 0) {
    return(NULL)  # Return NULL if no variables exist in category
  }
  
  df_subset <- df[, colnames(df) %in% variable_list, drop = FALSE]
  
  counts <- data.frame(
    `95` = sum(df_subset == 95, na.rm = TRUE),
    `97` = sum(df_subset == 97, na.rm = TRUE),
    `98` = sum(df_subset == 98, na.rm = TRUE),
    `99` = sum(df_subset == 99, na.rm = TRUE),
    `NA` = sum(is.na(df_subset))
  )
  
  return(counts)
}

# Loop through each variable category and count special codes
special_codes_summary <- do.call(
  bind_rows,
  lapply(names(variable_categories), function(category_name) {
    counts <- count_special_codes(variable_categories[[category_name]], df)
    if (!is.null(counts)) {
      counts$Variable_Category <- category_name
      return(counts)
    }
  })
)

# Reorder columns to put Variable_Category first
special_codes_summary <- special_codes_summary[, c("Variable_Category", "95", "97", "98", "99", "NA")]

# ------------------------------------------------
# Print or export results
print(special_codes_summary)

# Save as CSV:
write.csv(special_codes_summary, "data/private/metadata/2022/missingness_by_category_summary.csv", row.names = FALSE)

