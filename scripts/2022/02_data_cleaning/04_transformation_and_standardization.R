# --------------------------------------
# PISA 2022 Data Transformation and Standardization
# --------------------------------------
# Purpose:
# - Apply custom response mappings to recode categorical variables according to PISA coding guidelines.
# - Standardize response values for consistency across relevant variables.
# - Transform specific response codes (e.g., 5 → 95 for valid skips, 4 → 97 for not applicable cases).
# - Ensure all renamed variables align with the variable mapping table.
# - Save the transformed dataset for subsequent cleaning and analysis.

# Load required libraries
library(dplyr)

# Load the Stage 1 Cleaned Dataset
data_stage1 <- read.csv("data/private/processed/2022/pisa2022_cleaned_1_initial_data_removal.csv")

# Define custom response mappings for specific variables
response_mapping_general <- list(
  "7640001" = 1,  # None
  "7640002" = 2,  # One
  "7640003" = 3,  # Two
  "7640004" = 4,  # Three or more
  "9999999" = 99  # Missing
)

response_mapping_st250 <- list(
  "7640001" = 1,  # Yes
  "7640002" = 2,  # No
  "9999999" = 99  # No Response
)

response_mapping_st330 <- list(
  "7640001" = 1,  # Yes, once
  "7640002" = 2,  # Yes, two or more times
  "7640003" = 3,  # No
  "9999999" = 99  # No Response
)

# Apply custom mappings for each variable
data_stage2_step1 <- data_stage1 %>%
  mutate(
    # Apply the response mapping for ST250D06JA and ST250D07JA
    ST250D06JA = as.numeric(as.character(response_mapping_st250[as.character(ST250D06JA)])),
    ST250D07JA = as.numeric(as.character(response_mapping_st250[as.character(ST250D07JA)])),
    
    # Apply the response mapping for ST330D10WA
    ST330D10WA = as.numeric(as.character(response_mapping_st330[as.character(ST330D10WA)])),
    
    # Apply the general response mapping for ST251D08JA and ST251D09JA
    ST251D08JA = as.numeric(as.character(response_mapping_general[as.character(ST251D08JA)])),
    ST251D09JA = as.numeric(as.character(response_mapping_general[as.character(ST251D09JA)]))
  )

# Adjust responses for SC175Q01JA (transform 998 to 99998 for consistency)
data_stage2_step1 <- data_stage2_step1 %>%
  mutate(
    SC175Q01JA = ifelse(SC175Q01JA == 998, 99998, SC175Q01JA)
  )

# Transform 5 to 95 for Valid Skip in specific variables
valid_skip_variables <- c(
  "SC035Q01NA", "SC035Q01NB", "SC035Q02TA", "SC035Q02TB",
  "SC035Q03TA", "SC035Q03TB", "SC035Q04TA", "SC035Q04TB",
  "SC035Q05TA", "SC035Q05TB", "SC035Q06TA", "SC035Q06TB",
  "SC035Q07TA", "SC035Q07TB", "SC035Q08TA", "SC035Q08TB",
  "SC035Q09NA", "SC035Q09NB", "SC035Q10TA", "SC035Q10TB",
  "SC035Q11NA", "SC035Q11NB"
)

data_stage2_step1 <- data_stage2_step1 %>%
  mutate(across(
    all_of(valid_skip_variables),
    ~ ifelse(. == 5, 95, .)
  ))

# Transform 4 to 97 for Not Applicable in specific variables
not_applicable_variables <- c("SC177Q01JA", "SC177Q02JA", "SC177Q03JA")

data_stage2_step1 <- data_stage2_step1 %>%
  mutate(across(
    all_of(not_applicable_variables),
    ~ ifelse(. == 4, 97, .)
  ))

# Load the variable mapping table
variable_mapping <- read.csv("data/private/metadata/2022/pisa2022_variable_mapping_table.csv")

# Replace NA values in renamed_variable with the corresponding original_variable_name
variable_mapping$renamed_variable[is.na(variable_mapping$renamed_variable)] <- 
  variable_mapping$original_variable_name

# Rename variables in the dataset using the mapping table
names(data_stage2_step1) <- variable_mapping$renamed_variable[
  match(names(data_stage2_step1), variable_mapping$original_variable_name)
]

# Save the resulting transformation_and_standardization dataset
write.csv(
  data_stage2_step1,
  "data/private/processed/2022/pisa2022_cleaned_2_transformation_and_standardization.csv",
  row.names = FALSE
)

cat("Stage 2 Step 1 dataset saved to: data/private/processed/2022/pisa2022_cleaned_2_transformation_and_standardization.csv\n")
