# Load necessary libraries
library(dplyr)

# Step 1: Extract all variable names from the cleaned initial data removal dataset
data <- read.csv("data/processed/2022/pisa2022_cleaned_1_initial_data_removal.csv")
all_variable_names <- names(data)

# Step 2: Define variables to exclude from automated data source mapping
excluded_vars <- c(
  "STRATUM", "STUDYHMW", "SCHRISK", "STRESAGR", "SCHSUST", 
  "ICTRES", "ICTSCH", "ICTAVSCH", "ICTHOME", "ICTAVHOM", 
  "ICTQUAL", "ICTSUBJ", "ICTENQ", "ICTFEED", "ICTOUT", 
  "ICTWKDY", "ICTWKEND", "ICTREG", "ICTINFO", "ICTDISTR", 
  "ICTEFFIC", "STUBMI", "SCHLTYPE", "SCHSIZE", "STRATIO", 
  "SCHSEL", "SCHAUTO", "STAFFSHORT", "STUBEHA", "STDTEST", 
  "SCSUPRTED", "SCSUPRT", "SCPREPBP", "SCPREPAP"
)

# Step 3: Create the mapping table with all required columns
mapping_table <- data.frame(
  original_variable_name = all_variable_names,
  renamed_variable = NA,                # Placeholder for descriptive names
  variable_description = NA,            # Placeholder for variable descriptions
  data_source = NA,                     # Placeholder for data source identification
  year = 2022,                          # Assign year directly
  percentage_missing_data = NA,         # Placeholder for calculated missing data
  skip_logic = NA,                      # Placeholder for skip logic information
  implication_of_skips = NA,            # Placeholder for implications of skips
  data_type = NA,                       # Placeholder for variable data types
  pisa_domain = NA,                     # Placeholder for pisa questionnaire framework domain
  pisa_construct = NA,                  # Placeholder for PISA questionnaire framework construct
  pisa_ict_school_domain = NA,          # Placeholder for PISA ICT framework in-school domain
  pisa_ict_school_construct = NA,       # Placeholder for PISA ICT framework in-school construct
  pisa_ict_home_domain = NA,            # Placeholder for PISA ICT framework outside-the-classroom domain
  pisa_ict_home_construct = NA,         # Placeholder for PISA ICT framework outside-the-classroom construct
  mlftau_domain = NA,                   # Placeholder for MLFTAU domain
  mlftau_construct = NA,                # Placeholder for MLFTAU construct
  framework_overlap = NA,               # Placeholder for framework overlaps
  cross_year_compatibility = NA,        # Placeholder for cross-year compatibility
  action = NA,                          # Placeholder for necessary actions
  transformation_needed = NA,           # Placeholder for transformation needs
  reason = NA,                          # Placeholder for reasons behind actions
)

# Step 4: Assign `data_source` values while excluding certain variables from automated mapping
mapping_table <- mapping_table %>%
  mutate(
    data_source = case_when(
      original_variable_name %in% excluded_vars ~ NA_character_, # Exclude from automated mapping
      grepl("^ST", original_variable_name) ~ "student_questionnaire",
      grepl("^SC", original_variable_name) ~ "school_questionnaire",
      grepl("^IC", original_variable_name) ~ "ict_questionnaire",
      TRUE ~ "other_sources" # For variables outside known questionnaire categories
    )
  )

# Step 5: Calculate percentage missing data for all variables
mapping_table <- mapping_table %>%
  mutate(
    percentage_missing_data = sapply(
      original_variable_name,
      function(var) round(sum(is.na(data[[var]])) / nrow(data) * 100, 2)
    )
  )

# Step 6: Save the mapping table to the appropriate directory
# The pisa2022_variable_mapping_table.csv is a proprietary file 
# stored in the private folder for intellectual property protection.
# This script references it but does not expose its content.
write.csv(
  mapping_table,
  "data/private/metadata/2022/pisa2022_variable_mapping_table.csv",
  row.names = FALSE
)

cat("Mapping table saved to: data/private/metadata/2022/pisa2022_variable_mapping_table.csv\n")
