# --------------------------------------
# PISA 2022 Statistical Screening for Redundancy
# --------------------------------------
# Purpose: This script identifies redundant variables based on high correlations (> 0.85)
# and ensures that only meaningful, non-redundant variables are retained for analysis.
# --------------------------------------

# Load necessary libraries
library(readr)
library(dplyr)

# Read in the cleaned dataset
df <- read.csv("data/private/processed/2022/pisa2022_cleaned_15_flagging_procedures.csv")

# Function to extract variables in a given range
extract_variable_range <- function(df, start_var, end_var) {
  if (start_var %in% names(df) & end_var %in% names(df)) {
    return(names(df)[which(names(df) == start_var):which(names(df) == end_var)])
  } else {
    return(character(0))  # Return empty if any variable is missing
  }
}

# Extract relevant variables for screening
student_vars  <- extract_variable_range(df, "student_grade_level", "effort_accurate_pisa")
ict_vars      <- extract_variable_range(df, "school_use_desktop_laptop", "can_represent_solution_steps")
sdv_vars      <- extract_variable_range(df, "test_effort_actual", "parent_highest_occup")  # Derived
ictdv_vars    <- extract_variable_range(df, "ict_at_school", "ict_self_efficacy")  # Derived
school_vars   <- extract_variable_range(df, "community_type", "preparedness_remote_instruction")
scdv_vars     <- extract_variable_range(df, "school_type_derived", "digital_learning_preparedness")  # Derived

# Combine all selected variables
selected_vars <- c(student_vars, ict_vars, sdv_vars, ictdv_vars, school_vars, scdv_vars)

# Subset dataset to only include relevant variables
df_selected <- df %>% select(all_of(selected_vars))

# Function to determine variable type
get_var_type <- function(var) {
  if (var %in% c(student_vars, ict_vars, school_vars)) {
    return("Questionnaire Response")
  } else if (var %in% c(sdv_vars, ictdv_vars, scdv_vars)) {
    return("Derived Variable")
  } else {
    return("Unknown")
  }
}

# Compute % completeness for each variable
compute_completeness <- function(var) {
  valid_values <- sum(!is.na(var) & var != "valid_skip" & var != "random_skip")
  total_values <- length(var)
  round((valid_values / total_values) * 100, 1)  # Round to 1 decimal place
}

# Select only numeric variables for correlation analysis
numeric_vars <- df_selected %>% select_if(is.numeric)

# Compute completeness and variable type
completeness_df <- data.frame(
  Variable = colnames(numeric_vars),
  Completeness = sapply(numeric_vars, compute_completeness),
  Var_Type = sapply(colnames(numeric_vars), get_var_type)
)

# Compute correlation matrix
cor_matrix <- cor(numeric_vars, use = "complete.obs")

# Identify highly correlated pairs (correlation > 0.85)
high_correlation_pairs <- which(abs(cor_matrix) > 0.85, arr.ind = TRUE)
high_correlation_pairs <- high_correlation_pairs[high_correlation_pairs[,1] < high_correlation_pairs[,2], ]  # Remove duplicates

# Create a data frame to store the results
if (nrow(high_correlation_pairs) > 0) {
  correlated_vars <- data.frame(
    Variable1 = rownames(cor_matrix)[high_correlation_pairs[, 1]],
    Var1_Type = sapply(rownames(cor_matrix)[high_correlation_pairs[, 1]], get_var_type),
    Var1_Completeness = completeness_df$Completeness[match(rownames(cor_matrix)[high_correlation_pairs[, 1]], completeness_df$Variable)],
    
    Variable2 = rownames(cor_matrix)[high_correlation_pairs[, 2]],
    Var2_Type = sapply(rownames(cor_matrix)[high_correlation_pairs[, 2]], get_var_type),
    Var2_Completeness = completeness_df$Completeness[match(rownames(cor_matrix)[high_correlation_pairs[, 2]], completeness_df$Variable)],
    
    Correlation = round(cor_matrix[high_correlation_pairs], 2)  # **Round to 1 decimal place**
  )
  
  # Save the results to a CSV file in the specified folder
  write.csv(correlated_vars, "data/private/metadata/2022/statistical_screening_results.csv", row.names = FALSE)
  
  cat("The statistical screening results have been saved to 'data/private/metadata/2022/statistical_screening_results.csv'.\n")
} else {
  cat("No pairs with correlation greater than 0.85 were found.\n")
}
