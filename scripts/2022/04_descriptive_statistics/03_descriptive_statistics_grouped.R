# ------------------------------------------------------------
# PISA 2022 Descriptive Statistics with Conceptual Grouping
# ------------------------------------------------------------
# This script computes descriptive statistics for all variables in the final cleaned and imputed 
# PISA 2022 dataset, organizing the results according to three conceptual groupings:
# 1. PISA data source (Student Questionnaire, ICT Questionnaire, Student Derived Variables, 
# ICT Derived Variables, School Questionnaire, and School Derived Varaibles)
# 2. In-School, Outside-School, and In-and-Out-of-School learning contexts
# 3. PISA CIPO Domains (i.e., Context, Input, Process, Output)
#
# The script handles both numeric and categorical variables, flags extreme values (e.g., SD > 100, 
# skewness > 2, kurtosis > 3), and outputs a long-form CSV table for further analysis and validation.
# ------------------------------------------------------------

library(tidyverse)

# 0. paths
desc_long_path <- "output/private/descriptive_statistics/2022/pisa2022_descriptive_statistics_long.csv"
map_path       <- "data/private/metadata/2022/pisa2022_variable_mapping_table.csv"
grouped_path <- "output/private/descriptive_statistics/2022/pisa2022_descriptive_stats_grouped.csv"

# 1. read
desc <- read_csv(desc_long_path, show_col_types = FALSE)
map  <- read_csv(map_path, show_col_types = FALSE)

# 2. Capture original variable order
var_levels <- desc %>% 
  distinct(variable) %>% 
  pull(variable)

# 3. extract only the first pisa_domain label
map <- map %>%
  select(renamed_variable,
         broad_learning_context,
         pisa_domain) %>%
  mutate(
    # keep only the first label before any semicolon
    pisa_domain_primary = str_split(pisa_domain, ";", simplify = TRUE)[,1]
  )

# 4. join onto the long descriptive statistics file but carve out a separate pisa effort category
assessment_vars <- c(
  "effort_accurate_pisa",
  "effort_invested_marks_pisa",
  "effort_invested_pisa",
  "test_effort_actual",
  "test_effort_hypothetical"
)

desc_grouped <- desc %>%
  left_join(map, by = c("variable" = "renamed_variable")) %>%
  # Override category for assessment‐engagement items
  mutate(
    source_group = if_else(
      variable %in% assessment_vars,
      "Assessment Engagement",
      as.character(category)
    )
  ) %>%
  # Reorder columns, inserting the new source_group in place of category
  select(
    variable, variable_description,
    source_group,
    broad_learning_context,
    pisa_domain_primary,
    variable_type, statistic, value
  )

# 5. Arrange for reporting
desc_grouped <- desc_grouped %>%
  mutate(
    # preserve original variable order as a factor
    variable = factor(variable, levels = var_levels)
  ) %>%
  mutate(
    # force source_group into desired order
    source_group = factor(
      source_group,
      levels = c(
        "Student Questionnaire",
        "ICT Questionnaire",
        "Student Derived Variables",
        "ICT Derived Variables",
        "School Questionnaire",
        "School Derived Variables",
        "Assessment Engagement"
      )
    ),
    # force learning-context into desired order
    broad_learning_context = factor(
      broad_learning_context,
      levels = c("In School", "Out of School", "In and Out")
    ),
    # force CIPO into desired order
    pisa_domain_primary = factor(
      pisa_domain_primary,
      levels = c("Context", "Input", "Process", "Output")
    )
  ) %>%
  arrange(
    source_group,
    broad_learning_context,
    pisa_domain_primary,
    variable,
    statistic
  )

# 6. write out
write_csv(desc_grouped, grouped_path)

# 7. Debugging: any rows with missing grouping?
debug_grouping_path <- "data/private/metadata/2022/04_descriptive_statistics/pisa2022_desc_stats_missing_grouping_debug.csv"

missing_grouping <- desc_grouped %>%
  filter(
    source_group != "Assessment Engagement" &
      (is.na(broad_learning_context) | is.na(pisa_domain_primary))
  )

if (nrow(missing_grouping) > 0) {
  write_csv(missing_grouping, debug_grouping_path)
  cat("🔴 Missing grouping labels for", nrow(missing_grouping),
      "rows. See", debug_grouping_path, "\n")
} else {
  cat("✅ All non‐assessment variables have valid grouping labels.\n")
}

# Confirmation
cat("✅ Descriptive stats grouping complete.\n")