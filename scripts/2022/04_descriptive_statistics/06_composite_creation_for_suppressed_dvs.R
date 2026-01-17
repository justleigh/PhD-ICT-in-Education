# ------------------------------------------------------------
# Script: 06_composite_creation_for_suppressed_dvs.R
# Author: Leigh Pearson
# Project: PhD – ICT and Educational Outcomes in Thailand
# ------------------------------------------------------------
# Description:
# This script reconstructs all suppressed composite variables (DVs) 
# from the PISA 2022 dataset using raw questionnaire items. These include:
#
# - stdv_perseverance_agreement_self
# - icdv_ict_enquiry_learning_self
# - icdv_ict_support_feedback_self
# - icdv_ict_outside_class_self
# - scdv_digital_device_policies_self
# - scdv_diversity_multicultural_views_self
#
# Each composite is calculated as the row-wise mean of standardized 
# (z-scored) input items, with reverse coding applied where needed. 
# Final variables are inserted immediately after their original or 
# thematically associated derived counterparts in the dataset.
#
# Output:
# - Updated dataset saved as:
#   data/private/processed/2022/pisa2022_cleaned_19_composites_added.csv
#   data/private/processed/2022/pisa2022_cleaned_19_composites_added.rds
# ------------------------------------------------------------

# Load required libraries
library(dplyr)
library(readr)

# Load cleaned and prefixed dataset (v18)
input_file <- "data/private/processed/2022/pisa2022_cleaned_18_prefixed_variable_names.rds"
df <- readRDS(input_file)

cat("Loaded dataset with", nrow(df), "rows and", ncol(df), "columns.\n")

# ------------------------------------------------------------
# Composite 1: Perseverance Agreement (stdv_perseverance_agreement_self)
# ------------------------------------------------------------

# Step 1: Define reversed items with prefix
reversed_items <- c(
  "st_stop_difficult_task",
  "st_give_up_after_mistakes",
  "st_quit_long_homework",
  "st_give_up_easily"
)

# Step 2: Reverse code negatively worded items (1–4 Likert)
df <- df |>
  mutate(across(all_of(reversed_items), ~ 5 - as.numeric(.x)))

# Step 3: Define full item set used to build the composite
perseverance_items <- c(
  "st_persistence_task_finished",
  "st_extra_effort_challenging",
  "st_persistence_boring_task",
  "st_stop_difficult_task",
  "st_more_persistent_than_others",
  "st_give_up_after_mistakes",
  "st_quit_long_homework",
  "st_persistence_difficult_task",
  "st_finish_what_start",
  "st_give_up_easily"
)

# Step 4: Z-score each item (convert ordered factor to numeric)
df <- df |>
  mutate(across(all_of(perseverance_items),
                ~ scale(as.numeric(.x))[, 1],
                .names = "z_{.col}"))

# Step 5: Compute composite as mean of z-scores
df <- df |>
  rowwise() |>
  mutate(stdv_perseverance_agreement_self = mean(c_across(starts_with("z_")), na.rm = TRUE)) |>
  ungroup()

# Step 6: Remove temporary z-score columns
df <- df |>
  select(-starts_with("z_"))

# Step 7: Insert new variable after 'stdv_school_safety_risk'
insert_after <- which(names(df) == "stdv_school_safety_risk")
composite_vec <- df$stdv_perseverance_agreement_self

df <- df |>
  select(-stdv_perseverance_agreement_self)

df <- bind_cols(
  df[1:insert_after],
  stdv_perseverance_agreement_self = composite_vec,
  df[(insert_after + 1):ncol(df)]
)

# ✅ Confirm success
cat("✅ Composite 'stdv_perseverance_agreement_self' inserted after column", insert_after, "\n")

# ------------------------------------------------------------
# Composite 2: ICT Enquiry Learning (icdv_ict_enquiry_learning_self)
# ------------------------------------------------------------

# Define item set
ictenq_items <- c(
  "ic_digital_create_multimedia_presentation",
  "ic_digital_write_edit_text",
  "ic_digital_find_info_real_world",
  "ic_digital_collect_record_data",
  "ic_digital_analyze_data",
  "ic_digital_report_share_results",
  "ic_digital_plan_manage_projects",
  "ic_digital_track_progress",
  "ic_digital_collaborate_create_content",
  "ic_digital_play_learning_games"
)

# Confirm all items exist
missing_items <- ictenq_items[!ictenq_items %in% names(df)]
if (length(missing_items) > 0) {
  stop("❌ Missing variables: ", paste(missing_items, collapse = ", "))
}

# Z-score and average
df <- df |>
  mutate(across(all_of(ictenq_items),
                ~ scale(as.numeric(.x))[, 1],
                .names = "z_{.col}")) |>
  rowwise() |>
  mutate(icdv_ict_enquiry_learning_self = mean(c_across(starts_with("z_ic_digital_")), na.rm = TRUE)) |>
  ungroup() |>
  select(-starts_with("z_ic_digital_"))

# Insert after icdv_ict_use_subject_lessons
insert_after_2 <- which(names(df) == "icdv_ict_use_subject_lessons")
vec2 <- df$icdv_ict_enquiry_learning_self
df <- df |>
  select(-icdv_ict_enquiry_learning_self)
df <- bind_cols(
  df[1:insert_after_2],
  icdv_ict_enquiry_learning_self = vec2,
  df[(insert_after_2 + 1):ncol(df)]
)
cat("✅ Added icdv_ict_enquiry_learning_self after column", insert_after_2, "\n")

# ------------------------------------------------------------
# Composite 3: ICT Feedback and Support (icdv_ict_support_feedback_self)
# ------------------------------------------------------------

# Define relevant items
ictfeed_items <- c(
  "ic_digital_feedback_teacher",
  "ic_digital_feedback_peers",
  "ic_digital_feedback_auto_generated",
  "ic_digital_practice_exercises_apps"
)

# Validate presence
missing_ictfeed <- ictfeed_items[!ictfeed_items %in% names(df)]
if (length(missing_ictfeed) > 0) {
  stop("❌ Missing ICTFEED items: ", paste(missing_ictfeed, collapse = ", "))
}

# Z-score and compute mean
df <- df |>
  mutate(across(all_of(ictfeed_items),
                ~ scale(as.numeric(.x))[, 1],
                .names = "z_{.col}")) |>
  rowwise() |>
  mutate(icdv_ict_support_feedback_self = mean(c_across(starts_with("z_ic_digital_")), na.rm = TRUE)) |>
  ungroup() |>
  select(-starts_with("z_ic_digital_"))

# Insert after `icdv_ict_enquiry_learning_self`
insert_after_3 <- which(names(df) == "icdv_ict_enquiry_learning_self")
vec3 <- df$icdv_ict_support_feedback_self

df <- df |>
  select(-icdv_ict_support_feedback_self)

df <- bind_cols(
  df[1:insert_after_3],
  icdv_ict_support_feedback_self = vec3,
  df[(insert_after_3 + 1):ncol(df)]
)

cat("✅ Added icdv_ict_support_feedback_self after column", insert_after_3, "\n")

# ------------------------------------------------------------
# Composite 4: ICT Use Outside the Classroom (icdv_ict_outside_class_self)
# ------------------------------------------------------------

# Define relevant items
ictout_items <- c(
  "ic_digital_view_grades_results",
  "ic_digital_browse_schoolwork_info",
  "ic_digital_browse_lesson_followup",
  "ic_digital_receive_assignments_teacher",
  "ic_digital_upload_work",
  "ic_digital_communicate_teacher",
  "ic_digital_communicate_peers",
  "ic_digital_search_assignment_info"
)

# Validate presence
missing_ictout <- ictout_items[!ictout_items %in% names(df)]
if (length(missing_ictout) > 0) {
  stop("❌ Missing ICTOUT items: ", paste(missing_ictout, collapse = ", "))
}

# Z-score and compute row-wise mean
df <- df |>
  mutate(across(all_of(ictout_items),
                ~ scale(as.numeric(.x))[, 1],
                .names = "z_{.col}")) |>
  rowwise() |>
  mutate(icdv_ict_outside_class_self = mean(c_across(starts_with("z_ic_digital_")), na.rm = TRUE)) |>
  ungroup() |>
  select(-starts_with("z_ic_digital_"))

# Insert after `icdv_ict_support_feedback_self`
insert_after_4 <- which(names(df) == "icdv_ict_support_feedback_self")
vec4 <- df$icdv_ict_outside_class_self

df <- df |>
  select(-icdv_ict_outside_class_self)

df <- bind_cols(
  df[1:insert_after_4],
  icdv_ict_outside_class_self = vec4,
  df[(insert_after_4 + 1):ncol(df)]
)

cat("✅ Added icdv_ict_outside_class_self after column", insert_after_4, "\n")

# ------------------------------------------------------------
# Composite 5: Digital Device Policies (scdv_digital_device_policies_self)
# ------------------------------------------------------------

# Define relevant items
digdvpol_items <- c(
  "sc_written_statement_digital_devices",
  "sc_no_cell_phones_policy",
  "sc_formal_digital_guidelines",
  "sc_teacher_set_rules_digital_use",
  "sc_collab_student_rules_digital_use",
  "sc_responsible_internet_program",
  "sc_social_network_policy",
  "sc_collab_digital_teachers",
  "sc_teacher_meeting_digital_materials"
)

# Validate presence
missing_digdvpol <- digdvpol_items[!digdvpol_items %in% names(df)]
if (length(missing_digdvpol) > 0) {
  stop("❌ Missing DIGDVPOL items: ", paste(missing_digdvpol, collapse = ", "))
}

# Reverse score binary indicators (1 = Yes → 0, 0 = No → 1)
df <- df |>
  mutate(across(all_of(digdvpol_items), ~ 1 - as.numeric(.x)))

# Z-score and compute mean
df <- df |>
  mutate(across(all_of(digdvpol_items),
                ~ scale(.x)[, 1],
                .names = "z_{.col}")) |>
  rowwise() |>
  mutate(scdv_digital_device_policies_self = mean(c_across(starts_with("z_sc_")), na.rm = TRUE)) |>
  ungroup() |>
  select(-starts_with("z_sc_"))

# Insert after `scdv_tablet_availability`
insert_after_5 <- which(names(df) == "scdv_tablet_availability")
vec5 <- df$scdv_digital_device_policies_self

df <- df |>
  select(-scdv_digital_device_policies_self)

df <- bind_cols(
  df[1:insert_after_5],
  scdv_digital_device_policies_self = vec5,
  df[(insert_after_5 + 1):ncol(df)]
)

cat("✅ Added scdv_digital_device_policies_self after column", insert_after_5, "\n")

# ------------------------------------------------------------
# 🌍 Composite 6: Diversity and Multicultural Views (scdv_diversity_multicultural_views_self)
# ------------------------------------------------------------

# 🧩 Define relevant items
dmcviews_items <- c(
  "sc_staff_help_recognize_similarities",
  "sc_staff_encourage_common_ground",
  "sc_staff_support_diverse_identities",
  "sc_staff_teach_respond_discrimination",
  "sc_staff_teach_inclusivity",
  "sc_staff_support_disadvantaged"
)

# Validate presence
missing_dmcviews <- dmcviews_items[!dmcviews_items %in% names(df)]
if (length(missing_dmcviews) > 0) {
  stop("❌ Missing DMCVIEWS items: ", paste(missing_dmcviews, collapse = ", "))
}

# Z-score and compute mean
df <- df |>
  mutate(across(all_of(dmcviews_items),
                ~ scale(as.numeric(.x))[, 1],
                .names = "z_{.col}")) |>
  rowwise() |>
  mutate(scdv_diversity_multicultural_views_self = mean(c_across(starts_with("z_sc_")), na.rm = TRUE)) |>
  ungroup() |>
  select(-starts_with("z_sc_"))

# Insert after `scdv_math_teacher_training`
insert_after_6 <- which(names(df) == "scdv_math_teacher_training")
vec6 <- df$scdv_diversity_multicultural_views_self

df <- df |>
  select(-scdv_diversity_multicultural_views_self)

df <- bind_cols(
  df[1:insert_after_6],
  scdv_diversity_multicultural_views_self = vec6,
  df[(insert_after_6 + 1):ncol(df)]
)

cat("✅ Added scdv_diversity_multicultural_views_self after column", insert_after_6, "\n")

# ------------------------------------------------------------
# Save Final Output
# ------------------------------------------------------------

output_csv <- "data/private/processed/2022/pisa2022_cleaned_19_composites_added.csv"
output_rds <- "data/private/processed/2022/pisa2022_cleaned_19_composites_added.rds"

write_csv(df, output_csv)
saveRDS(df, output_rds)

cat("🎉 Saved updated dataset to:\n", output_csv, "\n", output_rds, "\n")