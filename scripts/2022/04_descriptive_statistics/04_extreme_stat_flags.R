# ---------------------------------------------
# PISA 2022 Descriptive Statistics: Outlier Flagging
# ---------------------------------------------
# Flags variables with:
# - Skewness > 2
# - Kurtosis > 3
# - Standard Deviation > 100
#
# Extracts flagged variables from the grouped descriptive stats table,
# adds issue type and source info for validation and reporting.
# ---------------------------------------------

library(dplyr)
library(readr)

# Load long-form descriptive statistics and variable metadata
desc_stats_grouped <- read_csv("output/private/descriptive_statistics/2022/pisa2022_descriptive_statistics_grouped.csv")
mapping_table <- read_csv("data/private/metadata/2022/pisa2022_variable_mapping_table.csv", show_col_types = FALSE)

# Helper: Get extreme values for absolute checks like skewness and kurtosis
get_extreme <- function(stat_name, threshold, label) {
  desc_stats_grouped %>%
    filter(Statistic == stat_name) %>%
    mutate(Value = as.numeric(Value)) %>%
    filter(!is.na(Value), abs(Value) > threshold) %>%
    select(Variable, data_source) %>%
    mutate(issue = label)
}

# Helper: Get extreme values for direct threshold checks like SD
get_extreme_direct <- function(stat_name, threshold, label) {
  desc_stats_grouped %>%
    filter(Statistic == stat_name) %>%
    mutate(Value = as.numeric(Value)) %>%
    filter(!is.na(Value), Value > threshold) %>%
    select(Variable, data_source) %>%
    mutate(issue = label)
}

# Get extreme values with labels
extreme_skew <- get_extreme("skewness", 2, "skewness > 2")
extreme_kurt <- get_extreme("kurtosis", 3, "kurtosis > 3")
extreme_sd   <- get_extreme_direct("sd", 100, "sd > 100")

# Combine all flagged variables
all_extremes <- bind_rows(extreme_skew, extreme_kurt, extreme_sd) %>%
  distinct() %>%
  arrange(Variable)

# Optional: Join with variable descriptions
all_extremes_labeled <- all_extremes %>%
  left_join(mapping_table %>% select(renamed_variable, variable_description, conceptual_group),
            by = c("Variable" = "renamed_variable")) %>%
  arrange(conceptual_group, Variable)

# Save
write_csv(all_extremes_labeled, "output/private/descriptive_statistics/2022/pisa2022_extreme_stat_flags.csv")

cat("💾 Extreme statistics report ready for review.\n")


