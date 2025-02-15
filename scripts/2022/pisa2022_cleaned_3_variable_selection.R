# Load necessary libraries
library(dplyr)
library(readr)

# File paths
mapping_table_path <- "data/private/metadata/2022/pisa2022_variable_mapping_table.csv"
student_data_path <- "data/private/processed/2022/pisa2022_cleaned_2_transformation_and_standardization.csv"
na_summary_output_path <- "data/private/metadata/2022/pisa2022_students_with_detailed_na_summary.csv"
cleaned_data_output_path <- "data/private/processed/2022/pisa2022_cleaned_3_variable_selection.csv"

# Load data
mapping_table <- read_csv(mapping_table_path)
student_data <- read_csv(student_data_path)

# Excluded variables
excluded_variables <- c(
  "STRATUM", "STUDYHMW", "STRESAGR", "ICTRES", "ICTSCH", "ICTAVSCH", "ICTHOME", 
  "ICTAVHOM", "ICTQUAL", "ICTSUBJ", "ICTENQ", "ICTFEED", "ICTOUT", "ICTWKDY", 
  "ICTWKEND", "ICTREG", "ICTINFO", "ICTDISTR", "ICTEFFIC", "STUBMI", "STRATIO", 
  "STAFFSHORT", "STUBEHA", "STDTEST"
)

# Step 1: Filter relevant variables
relevant_variables <- mapping_table %>%
  filter(
    grepl("^ST|^IC", original_variable_name) & 
      !original_variable_name %in% excluded_variables
  ) %>%
  pull(renamed_variable)

# Ensure variables exist in the dataset
relevant_variables <- intersect(relevant_variables, colnames(student_data))

# Step 2: Filter data for relevant variables
student_data_filtered <- student_data %>%
  select(student_id, all_of(relevant_variables))

# Step 3: Calculate missing data counts and percentages
student_data_summary <- student_data_filtered %>%
  rowwise() %>%
  mutate(
    # Count NA, 98, and 99 values
    total_na = sum(is.na(c_across(-student_id))),
    total_invalid = sum(c_across(-student_id) == 98, na.rm = TRUE),
    total_no_response = sum(c_across(-student_id) == 99, na.rm = TRUE),
    
    # Combined missing values (NA + 98 + 99)
    combined_missing = total_na + total_invalid + total_no_response,
    
    # Total number of relevant variables
    total_variables = length(c_across(-student_id)),
    
    # Calculate percentage of combined missing data
    combined_missing_percent = round((combined_missing / total_variables) * 100, 1)
  ) %>%
  ungroup() %>%
  select(
    student_id, total_na, total_invalid, total_no_response, 
    combined_missing, combined_missing_percent, everything()
  )  # Keep all variables for detailed analysis

# Step 4: Save detailed NA summary
write_csv(student_data_summary, na_summary_output_path)
cat("Detailed NA summary saved to:", na_summary_output_path, "\n")

# Step 5: Identify students with >20% missing responses
students_to_exclude <- student_data_summary %>%
  filter(combined_missing_percent > 20) %>%
  pull(student_id)

# Step 6: Exclude flagged students from the full dataset
cleaned_data <- student_data %>%
  filter(!student_id %in% students_to_exclude)

# Save the cleaned dataset
write_csv(cleaned_data, cleaned_data_output_path)
cat("Cleaned dataset saved to:", cleaned_data_output_path, "\n")

# Print summary of the filtering process
num_students_excluded <- length(students_to_exclude)
cat("Number of students excluded:", num_students_excluded, "\n")
cat("Number of students retained:", nrow(cleaned_data), "\n")
