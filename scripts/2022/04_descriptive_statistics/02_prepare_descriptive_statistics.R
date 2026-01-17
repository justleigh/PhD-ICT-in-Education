# --------------------------------------
# Descriptive Statistics Computation
# --------------------------------------
# - Compute descriptive statistics (mean, SE, SD, quantiles, skewness, kurtosis)
#   for all “Included” variables
# - Handle both numeric and categorical variables (proportions + mode)
# - Apply Fay-BRR replicate weights (W_FSTUWT + W_FSTURWT1…W_FSTURWT80)
# - Separate designs for student-level and school-level variables:
#   - Student-level stats use full student sample (after flag exclusion)
#   - School-level stats use unique school records (1 row per school_id)
# - Produce a long (“tidy”) output for QA
# - Include debug flags for empty stats, extreme CV, missing variables
# --------------------------------------

library(tidyverse)
library(survey)

# File paths
input_path         <- "data/private/processed/2022/pisa2022_cleaned_16_final_cleaned_data.rds"
mapping_table_path <- "data/private/metadata/2022/pisa2022_variable_mapping_table.csv"
output_long_path   <- "output/private/descriptive_statistics/2022/pisa2022_descriptive_statistics_long.csv"

# Debug file paths
debug_empty_vars      <- "data/private/metadata/2022/04_descriptive_statistics/pisa2022_desc_stats_empty_vars_debug.csv"
debug_high_cv         <- "data/private/metadata/2022/04_descriptive_statistics/pisa2022_desc_stats_high_cv_debug.csv"
debug_missing_included <- "data/private/metadata/2022/04_descriptive_statistics/pisa2022_desc_stats_missing_included_debug.csv"
debug_skew_kurt_path  <- "data/private/metadata/2022/04_descriptive_statistics/pisa2022_desc_stats_skew_kurtosis_debug.csv"
debug_high_sd_path          <- "data/private/metadata/2022/04_descriptive_statistics/pisa2022_desc_stats_extreme_sd_debug.csv"

# 1. Load data and mapping
df            <- read_rds(input_path)
mapping_table <- read_csv(mapping_table_path, show_col_types = FALSE)
# Build a named vector of types
var_types    <- mapping_table %>%
  select(renamed_variable, cleaned_data_type) %>%
  deframe()

# Identify those declared "NUM" in your metadata
numeric_vars <- names(var_types)[var_types == "NUM"]

# **Filter out any that don't actually exist in df**
numeric_vars <- intersect(numeric_vars, colnames(df))

# Coerce them all to true numeric
df <- df %>%
  mutate(across(all_of(numeric_vars),
                ~ as.numeric(as.character(.))))

# 2. Helper to count skip codes in any vector
count_skips <- function(x) {
  x_chr <- as.character(x)
  tibble(
    n_valid_skip  = sum(x_chr == "valid_skip",  na.rm = TRUE),
    n_random_skip = sum(x_chr == "random_skip", na.rm = TRUE),
    n_missing     = sum(is.na(x_chr))
  )
}

# 3. Flag filtering: exclude students with ≥2 flags
flag_vars <- c(
  "perception_straight_line_flag",
  "feeling_straight_line_flag",
  "persistence_straight_line_flag",
  "math_class_periods_flag",
  "total_class_periods_flag"
)

# ensure flags exist
missing_flags <- setdiff(flag_vars, colnames(df))
if (length(missing_flags) > 0) {
  stop("These flag columns are not in df: ", paste(missing_flags, collapse = ", "))
}

# count flags per student
df <- df %>%
  mutate(n_flags = rowSums(across(all_of(flag_vars), ~ . == "Flagged" & !is.na(.))))

# record before/after counts
n_before <- nrow(df)
df <- df %>% filter(n_flags < 2) %>% select(-n_flags)
n_after  <- nrow(df)

# report how many were removed
message(glue::glue(
  "{n_before - n_after} students removed due to ≥2 flags; ",
  "{n_after} students remain."
))

# 4. Select “Included” variables
exclude_patterns <- c(
  "^PV\\d", "^W_FSTR", "WVARSTRR", "SENWT", "VER_DAT",
  "^country_id$", "^school_id$", "^student_id$",
  "^assessment_cycle$", "^sampling_stratum$",
  "^subnational_region$", "^administration_mode$"
)
included_vars <- mapping_table %>%
  filter(
    status == "Included",
    !str_detect(pisa_construct, "\\bGlobal Crises\\b"),
    (input_variable == "No" | derived_variable == "Yes")
  ) %>%
  pull(renamed_variable) %>%
  intersect(colnames(df)) %>%
  keep(~ !str_detect(.x, paste(exclude_patterns, collapse="|")))

# 5. Define variable blocks
extract_filtered_variables <- function(df, start_var, end_var, selected) {
  cols <- colnames(df)
  i1 <- which(cols == start_var)
  i2 <- which(cols == end_var)
  if (!length(i1) || !length(i2)) return(character())
  intersect(cols[i1:i2], selected)
}
student_vars <- extract_filtered_variables(df, "student_grade_level",      "effort_accurate_pisa",           included_vars)
ict_vars     <- extract_filtered_variables(df, "school_use_desktop_laptop", "can_represent_solution_steps",   included_vars)
sdv_vars     <- extract_filtered_variables(df, "test_effort_actual",        "escs_index",                     included_vars)
ictdv_vars   <- extract_filtered_variables(df, "ict_at_school",             "ict_self_efficacy",              included_vars)
school_vars  <- extract_filtered_variables(df, "community_type",            "preparedness_remote_instruction",included_vars)
scdv_vars    <- extract_filtered_variables(df, "school_type_derived",       "digital_learning_preparedness",  included_vars)

# 6. Create school-level data frame for school-level variables
df_schools <- df %>%
  distinct(school_id, .keep_all = TRUE)

message(glue::glue("School-level analysis based on {nrow(df_schools)} unique schools."))

# 7. Build survey design with Fay-BRR
rep_weights <- paste0("W_FSTURWT", 1:80)
design <- svrepdesign(
  weights    = ~W_FSTUWT,
  repweights = as.matrix(df[rep_weights]),
  data       = df,
  type       = "Fay",
  rho        = 0.5
)

# 8. Build survey design for school-level variables (no weighting needed, but included for consistency)
design_school <- svrepdesign(
  weights    = ~W_FSTUWT,
  repweights = as.matrix(df_schools[rep_weights]),
  data       = df_schools,
  type       = "Fay",
  rho        = 0.5
)

# 9. Compute descriptive stats (long/tidy)
compute_descriptive_stats <- function(design, vars, category) {
  map_dfr(vars, function(var) {
    # 1) pull raw vector from survey design
    v_raw <- design$variables[[var]]
    
    # 2) count skips/missing via helper
    skips        <- count_skips(v_raw)
    n_valid_skip <- skips$n_valid_skip
    n_random_skip<- skips$n_random_skip
    n_missing    <- skips$n_missing
    
    # 3) look up declared type: "NUM" vs everything else
    this_type <- var_types[[var]]
    
    if (this_type != "NUM") {
      valid_vals  <- !design$variables[[var]] %in% c("valid_skip", "random_skip") & !is.na(design$variables[[var]])
      design_sub  <- subset(design, valid_vals)
      
      prop_obj    <- svymean(reformulate(paste0("factor(", var, ")")), design_sub, na.rm = TRUE)
      lvl2_raw    <- names(coef(prop_obj))                             # e.g. "factor(var)Level"
      lvl2_label  <- str_remove(lvl2_raw, "^.*\\)") %>% tolower()      # Just "level", lowercase
      valid_indices <- seq_along(lvl2_label)  # All indices now valid since we've filtered earlier
      
      prop_names  <- paste0("prop_", lvl2_label[valid_indices])
      props       <- as.numeric(coef(prop_obj))[valid_indices]
      mode_lvl    <- lvl2_label[which.max(props)]
      
      return(tibble(
        variable  = var,
        statistic = c("n_valid_skip", "n_random_skip", "n_missing", prop_names, "mode"),
        value     = as.character(c(n_valid_skip, n_random_skip, n_missing, props, mode_lvl)),
        category  = category
      ))
    }
    
    # --- numeric branch ---
    v_chr <- as.character(v_raw)
    suppressWarnings({
      v_num <- as.numeric(v_chr)
      v_num[v_chr %in% c("valid_skip","random_skip")] <- NA
    })
    
    mean_obj  <- svymean(reformulate(var), design, na.rm = TRUE)
    se_m      <- survey::SE(mean_obj)
    var_obj   <- svyvar (reformulate(var), design, na.rm = TRUE)
    quant_obj <- svyquantile(reformulate(var), design,
                             c(0, .25, .5, .75, 1), na.rm = TRUE)
    wts       <- design$variables$W_FSTUWT
    m         <- coef(mean_obj)
    s2        <- coef(var_obj)
    s         <- sqrt(s2)
    skew      <- sum(wts * (v_num - m)^3, na.rm=TRUE) /
      sum(wts, na.rm=TRUE) / (s^3)
    kurt      <- sum(wts * (v_num - m)^4, na.rm=TRUE) /
      sum(wts, na.rm=TRUE) / (s2^2) - 3
    
    tibble(
      variable  = var,
      statistic = c(
        "n_valid_skip","n_random_skip","n_missing",
        "mean","se_mean","sd","min","q25","median","q75","max",
        "skewness","kurtosis"
      ),
      value     = as.character(c(
        n_valid_skip, n_random_skip, n_missing,
        m, se_m, s,
        coef(quant_obj)[1:5],
        skew, kurt
      )),
      category  = category
    )
  })
}

# 10. Compute and save long-form descriptive stats
desc_stats_long <- bind_rows(
  compute_descriptive_stats(design, student_vars, "Student Questionnaire"),
  compute_descriptive_stats(design, ict_vars,     "ICT Questionnaire"),
  compute_descriptive_stats(design, sdv_vars,     "Student Derived Variables"),
  compute_descriptive_stats(design, ictdv_vars,   "ICT Derived Variables"),
  compute_descriptive_stats(design_school, school_vars,  "School Questionnaire"),
  compute_descriptive_stats(design_school, scdv_vars,    "School Derived Variables")
)

# 11. Debugging checks
# 11.1 Empty–stats
desc_stats_debug_empty <- desc_stats_long %>%
  pivot_wider(
    names_from = statistic,
    values_from = value,
    values_fn = list(value = ~ .x[1])
  ) %>%
  filter(if_all(-c(variable, category), ~ is.na(.) | . == ""))

write_csv(desc_stats_debug_empty, debug_empty_vars)
cat("🟠 Empty variables:", nrow(desc_stats_debug_empty), "\n")

# 11.2 High-CV (sd > mean)
desc_stats_debug_high_cv <- desc_stats_long %>%
  filter(statistic %in% c("mean", "sd")) %>%
  pivot_wider(
    names_from = statistic,
    values_from = value,
    values_fn = list(value = ~ .x[1])
  ) %>%
  mutate(
    mean = as.numeric(mean),
    sd   = as.numeric(sd),
    cv   = sd / abs(mean),
    is_likely_standardized = abs(mean) < 0.2 & abs(sd - 1) < 0.2,  # 🎯 Flag standard-like behavior
    flag_type = case_when(
      is_likely_standardized ~ "Standardized Index (Ignore)",
      TRUE                   ~ "High CV"
    )
  ) %>%
  filter(cv > 1) %>%
  mutate(
    mean = round(mean, 2),
    sd   = round(sd, 2),
    cv   = round(cv, 2)
  ) %>%
  select(variable, category, mean, sd, cv, is_likely_standardized, flag_type) %>%
  arrange(desc(cv))

write_csv(desc_stats_debug_high_cv, debug_high_cv)
cat("🟠 High-CV variables flagged:", nrow(desc_stats_debug_high_cv), "\n")

# 11.3 Missing from “Included”
expected_vars <- mapping_table %>%
  filter(
    status == "Included",
    pisa_construct != "Global Crises",
    (input_variable == "No" | derived_variable == "Yes")
  ) %>%
  pull(renamed_variable)

missing_from_output <- setdiff(expected_vars, desc_stats_long$variable)

if (length(missing_from_output)) {
  write_csv(tibble(variable = missing_from_output), debug_missing_included)
  cat("🔵 Variables marked 'Included' but missing from output:", length(missing_from_output), "\n")
}

desc_stats_debug_skew_kurt <- desc_stats_long %>%
  filter(statistic %in% c("skewness", "kurtosis")) %>%
  mutate(value = round(as.numeric(value), 2)) %>%
  filter(value > if_else(statistic == "kurtosis", 3, 2))

if (nrow(desc_stats_debug_skew_kurt)) {
  write_csv(desc_stats_debug_skew_kurt, debug_skew_kurt_path)
  cat("⚠️ Extreme skewness/kurtosis flagged for", nrow(desc_stats_debug_skew_kurt), "rows.\n")
}

# 11.5 High Standard Deviation (sd > 100)
desc_stats_debug_high_sd <- desc_stats_long %>%
  filter(statistic %in% c("mean", "sd")) %>%
  pivot_wider(
    names_from = statistic,
    values_from = value,
    values_fn = list(value = ~ .x[1])
  ) %>%
  mutate(
    mean = round(as.numeric(mean), 2),
    sd   = round(as.numeric(sd), 2),
    flag = if_else(sd > 100, "High SD", "Normal")
  ) %>%
  filter(flag == "High SD") %>%
  select(variable, category, mean, sd, flag) %>%
  arrange(desc(sd))

write_csv(desc_stats_debug_high_sd, debug_high_sd_path)
cat("🔶 High SD variables flagged:", nrow(desc_stats_debug_high_sd), "\n")

# 12. Re-attach metadata (labels + types)
desc_stats_long <- desc_stats_long %>%
  left_join(
    mapping_table %>%
      select(renamed_variable, variable_description, cleaned_data_type) %>%
      rename(variable_type = cleaned_data_type),
    by = c("variable" = "renamed_variable")
  ) %>%
  mutate(
    num_tmp = suppressWarnings(as.numeric(value)),
    value = case_when(
      statistic %in% c("mean", "se_mean", "sd", "min", "q25", "median", "q75", "max", "skewness", "kurtosis") |
        str_detect(statistic, "^prop_") & !is.na(num_tmp) ~ sprintf("%.3f", num_tmp),
      TRUE ~ value
    )
  ) %>%
  select(-num_tmp) %>%
  select(variable, variable_description, variable_type, category, statistic, value)


write_csv(desc_stats_long, output_long_path)
cat("✅ Descriptive statistics complete.\n")
