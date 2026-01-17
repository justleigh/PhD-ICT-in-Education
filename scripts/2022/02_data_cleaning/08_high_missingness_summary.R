# Load necessary libraries
library(dplyr)
library(readr)
library(tidyr)

# File paths
student_data_path <- "data/private/processed/2022/pisa2022_cleaned_3_variable_selection.csv"
missingness_summary_path <- "data/private/metadata/2022/pisa2022_missingness_summary.csv"

# Load the filtered student data
student_data <- read_csv(student_data_path)

# Calculate Missingness Percentages (NA, 98, and 99 as missing)
variable_missingness <- student_data %>%
  summarise(across(
    everything(),
    ~ round(sum(is.na(.) | . == 98 | . == 99, na.rm = TRUE) / n() * 100, 2)
  )) %>%
  pivot_longer(cols = everything(), names_to = "variable", values_to = "missingness_percent") %>%
  arrange(desc(missingness_percent))

# Save the missingness summary
write_csv(variable_missingness, missingness_summary_path)
cat("Missingness summary saved to:", missingness_summary_path, "\n")
