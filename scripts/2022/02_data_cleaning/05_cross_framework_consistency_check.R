# --------------------------------------
# PISA 2022 Cross-Framework Consistency Table Creation
# --------------------------------------
# This Script:
# - Identifies questionnaire and derived variables with different domain labels across frameworks.
# - Focuses on pisa_domain, pisa_ict_school_domain, and pisa_ict_home_domain only.
# - Ignores variables labeled "Not Applicable" in any domain column.
# - Includes only variables that have:
#   - Valid domain labels (not "Not Applicable") in at least two columns.
#   - Different domain labels across columns.
# - Saves a clean table showing renamed_variable, pisa_domain, pisa_ict_school_domain, and pisa_ict_home_domain.
# --------------------------------------

library(dplyr)
library(readr)
library(stringr)

# --- Load your variable mapping table ---
mapping <- read_csv("data/private/metadata/2022/pisa2022_variable_mapping_table.csv", show_col_types = FALSE)

# --- Filter only questionnaire and derived variables ---
mapping_filtered <- mapping %>%
  filter(input_variable == "No" | derived_variable == "Yes")

# --- Create a temporary table ignoring "Not Applicable" ---
mapping_temp <- mapping_filtered %>%
  select(renamed_variable, pisa_domain, pisa_ict_school_domain, pisa_ict_home_domain) %>%
  mutate(across(c(pisa_domain, pisa_ict_school_domain, pisa_ict_home_domain), 
                ~ na_if(.x, "Not Applicable")))  # Turn "Not Applicable" into NA for easier filtering

# --- Create counts (but keep them only temporarily) ---
mapping_with_counts <- mapping_temp %>%
  rowwise() %>%
  mutate(
    valid_domains = list(na.omit(c(pisa_domain, pisa_ict_school_domain, pisa_ict_home_domain))),
    domains_present = length(valid_domains),
    domains_unique = length(unique(valid_domains))
  ) %>%
  ungroup()

# --- Now filter based on the counts ---
mapping_consistency_issues <- mapping_with_counts %>%
  filter(domains_present >= 2, domains_unique >= 2) %>%
  select(renamed_variable, pisa_domain, pisa_ict_school_domain, pisa_ict_home_domain)  # << 🧹 Final clean table: Drop counts here

# --- Save the output ---
write_csv(mapping_consistency_issues, "data/private/metadata/2022/variable_cross_framework_consistency_table.csv")

cat("✅ Consistency table saved at: data/private/metadata/2022/variable_cross_framework_consistency_table.csv\n")
