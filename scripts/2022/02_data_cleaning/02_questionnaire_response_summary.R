# --------------------------------------
# PISA 2022 Questionnaire Response Summary with Labels
# --------------------------------------
# Purpose: This script creates a detailed summary of student and ICT questionnaire responses by:
# 1. Selecting and pivoting the cleaned PISA 2022 dataset into long format
# 2. Calculating response frequencies and percentages for each variable–value pair
# 3. Mapping original PISA variable codes to friendly names and question descriptions
# 4. Reading and cleaning the PISA codebook to extract and normalize value labels
# 5. Merging human-readable labels into the response summary
# 6. Preserving the original variable order and exporting the final table for downstream analysis
# --------------------------------------

# === Load Required Libraries ===
library(dplyr)
library(tidyr)
library(readr)

# === 1. Read the cleaned PISA dataset (columns are original PISA codes) ===
data <- read_csv(
  "data/private/processed/2022/pisa2022_cleaned_1_initial_data_removal.csv",
  show_col_types = FALSE
)

# === 2. Read the variable mapping table (orig code → friendly name + description) ===
mapping_table <- read_csv(
  "data/private/metadata/2022/pisa2022_variable_mapping_table.csv",
  show_col_types = FALSE
) %>%
  rename_with(tolower)
# mapping_table now has: original_variable_name, renamed_variable, variable_description

# === 3. Read & clean the PISA codebook CSV (skip rows 1–2, fill down NAME) ===
raw_cb <- read_csv(
  "data/metadata/2022/pisa2022_codebook.csv",
  skip = 2,
  show_col_types = FALSE
)

codebook <- raw_cb %>%
  select(NAME, VAL, LABEL) %>%
  fill(NAME, .direction = "down") %>%
  transmute(
    original_variable_name = NAME,
    value                  = sub(".*?/", "", VAL),  # strip any prefix (e.g. ".V/")
    label                  = LABEL
  ) %>%
  mutate(value = as.character(value))

# === 4. Decide which PISA items to include/exclude ===
include_vars <- grep("^(ST|IC|SC)", names(data), value = TRUE)
exclude_vars <- c(
  "STRATUM","STUDYHMW","SCHRISK","STRESAGR","SCHSUST",
  "ICTRES","ICTSCH","ICTAVSCH","ICTHOME","ICTAVHOM",
  "ICTQUAL","ICTSUBJ","ICTENQ","ICTFEED","ICTOUT",
  "ICTWKDY","ICTWKEND","ICTREG","ICTINFO","ICTDISTR",
  "ICTEFFIC","STUBMI","SCHLTYPE","SCHSIZE","STRATIO",
  "SCHSEL","SCHAUTO","STAFFSHORT","STUBEHA","STDTEST",
  "SCSUPRTED","SCSUPRT","SCPREPBP","SCPREPAP"
)
vars_to_include <- setdiff(include_vars, exclude_vars)
data_filtered   <- data %>% select(all_of(vars_to_include))

# === 5. Pivot long & compute frequency + percentage ===
response_summary <- data_filtered %>%
  pivot_longer(
    cols      = everything(),
    names_to  = "variable",
    values_to = "value"
  ) %>%
  group_by(variable, value) %>%
  summarise(frequency = n(), .groups = "drop") %>%
  group_by(variable) %>%
  mutate(percentage = round(100 * frequency / sum(frequency), 2)) %>%
  ungroup() %>%
  mutate(value = as.character(value))

# === 6. Preserve dataset order and sort values numerically ===
variable_order    <- names(data_filtered)
response_summary  <- response_summary %>%
  mutate(variable = factor(variable, levels = variable_order)) %>%
  mutate(value_num = as.numeric(value)) %>%
  arrange(variable, value_num) %>%
  select(-value_num)

# === 7. Join in mapping metadata & codebook labels ===
response_full <- response_summary %>%
  # bring in friendly names & question text
  left_join(
    mapping_table %>% select(original_variable_name,
                             renamed_variable,
                             variable_description),
    by = c("variable" = "original_variable_name")
  ) %>%
  # bring in the human-readable label
  left_join(
    codebook,
    by = c("variable" = "original_variable_name",
           "value"    = "value")
  )

# === 8. Blank out repeated metadata, keep label on every row ===
final_summary <- response_full %>%
  group_by(variable) %>%
  mutate(
    # only show on first row of each block
    variable             = if_else(row_number() == 1, variable, ""),
    original_variable_name = if_else(row_number() == 1, variable, ""),
    renamed_variable       = if_else(row_number() == 1, renamed_variable, ""),
    variable_description   = if_else(row_number() == 1, variable_description, "")
    # leave `label`, `frequency`, `percentage` intact on all rows
  ) %>%
  ungroup() %>%
  select(
    variable,
    original_variable_name,
    renamed_variable,
    variable_description,
    value,
    label,
    frequency,
    percentage
  )

# === 9. Export to CSV ===
write_csv(
  final_summary,
  "data/private/metadata/2022/pisa2022_questionnaire_response_summary_with_mapping.csv"
)

cat("✅ Saved: data/private/metadata/2022/pisa2022_questionnaire_response_summary_with_mapping.csv\n")
