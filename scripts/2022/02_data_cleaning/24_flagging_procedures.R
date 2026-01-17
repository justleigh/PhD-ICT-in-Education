# --------------------------------------
# PISA 2022 Flagging Procedures for Data Quality Issues
# --------------------------------------
# Purpose: This script identifies and flags potential data quality issues in the PISA 2022 dataset by:
# 1. Flagging COVID-19 inconsistencies
# 2. Detecting and flagging straight-lining in students' perception of their teacher responses  
# 3. Detecting and flagging straight-lining in student personal feelings responses  
# 4. Calculating summary statistics  
# 5. Saving the updated dataset 

# Load necessary libraries
library(dplyr)      # For data manipulation (filtering, grouping, summarizing)  
library(readr)      # For reading and writing CSV files  
library(tidyr)      # For handling missing values and reshaping data  
library(stringr)    # For working with string operations (if needed for text processing)  

# CSV and RDS helper Function
save_cleaned <- function(df, csv_path) {
  write_csv(df, csv_path)
  rds_path <- str_replace(csv_path, ".csv$", ".rds")
  saveRDS(df, rds_path)
  cat("✅ Data saved as CSV:", csv_path, "\n")
  cat("✅ Data saved as RDS:", rds_path, "\n")
}

# --------------------------------------
# Step 1: Flagging COVID-19 inconsistencies
# --------------------------------------

# Load the cleaned student dataset before making changes
df <- readRDS("data/private/processed/2022/pisa2022_cleaned_14_school_dv_cleaning.rds")

# Create the covid_inconsistency_flag column
df <- df %>%
  mutate(
    covid_inconsistency_flag = ifelse(
      (school_closure_covid == "No" & school_days_closed_covid != 0) |
        (school_closure_covid != "No" & school_days_closed_covid == 0),
      "Flagged", "Not flagged"
    )
  ) %>%
  relocate(covid_inconsistency_flag, .after = school_closure_covid)  # Move flag column right after school_closure_covid

# Check summary
table(df$covid_inconsistency_flag, useNA = "ifany")

# --------------------------------------
# Step 2: Detecting and flagging straight-lining in students' perception of their teacher responses
# --------------------------------------

# Define teacher perception variables (randomized subset)
teacher_perception_vars <- c(
  "teacher_respectful", "teacher_concerned", "teacher_receptive", 
  "teacher_intimidating", "teacher_inquisitive", "teacher_friendly", 
  "teacher_wellbeing_interest", "teacher_mean"
)

# Identify students who provided identical responses across all presented teacher perception variables
df <- df %>%
  rowwise() %>%
  mutate(perception_straight_line_flag = ifelse(
    # Check if at least one negative item (teacher_intimidating or teacher_mean) is present
    any(!is.na(c_across(c("teacher_intimidating", "teacher_mean"))) & 
          c_across(c("teacher_intimidating", "teacher_mean")) != "random_skip") &
      # Check if all non-skipped responses are identical
      length(unique(na.omit(c_across(all_of(teacher_perception_vars)))[
        c_across(all_of(teacher_perception_vars)) != "random_skip"
      ])) == 1, 
    "Flagged", "Not flagged"
  )) %>%
  ungroup() %>%
  relocate(perception_straight_line_flag, .after = teacher_mean)

# Count the number of flagged students
perception_straight_line_count <- sum(df$perception_straight_line_flag == "Flagged")

# --------------------------------------
# Step 3: Detecting and flagging straight-lining in student personal feelings responses
# --------------------------------------

# Define student feelings variables (randomized subset)
student_feelings_vars <- c(
  "student_feels_outsider", "student_makes_friends", "student_belongs",
  "student_feels_awkward", "student_liked_by_others", "student_feels_lonely"
)

# Identify students who provided identical responses across all presented student feelings variables
df <- df %>%
  rowwise() %>%
  mutate(feeling_straight_line_flag = ifelse(
    length(unique(na.omit(c_across(all_of(student_feelings_vars)))[
      c_across(all_of(student_feelings_vars)) != "random_skip"
    ])) == 1, "Flagged", "Not flagged"
  )) %>%
  ungroup() %>%
  relocate(feeling_straight_line_flag, .after = student_feels_lonely)

# Count the number of flagged students
feeling_straight_line_count <- sum(df$feeling_straight_line_flag == "Flagged")

# --------------------------------------
# Step 4: Detecting and flagging straight-lining in persistence responses
# --------------------------------------

# Define persistence variables (randomized subset)
persistence_vars <- c(
  "persistence_task_finished", "extra_effort_challenging", 
  "persistence_boring_task", "stop_difficult_task", 
  "more_persistent_than_others", "give_up_after_mistakes", 
  "quit_long_homework", "persistence_difficult_task", 
  "finish_what_start", "give_up_easily"
)

# Identify students who provided identical responses across all presented persistence variables
df <- df %>%
  rowwise() %>%
  mutate(
    persistence_responses = list(c_across(all_of(persistence_vars))),
    filtered_responses = list(na.omit(c_across(all_of(persistence_vars)))[
      c_across(all_of(persistence_vars)) != "random_skip"
    ]),
    persistence_straight_line_flag = ifelse(
      length(unique(na.omit(c_across(all_of(persistence_vars)))[
        c_across(all_of(persistence_vars)) != "random_skip"
      ])) == 1, "Flagged", "Not flagged"
    )
  ) %>%
  ungroup() %>%
  relocate(persistence_straight_line_flag, .after = give_up_easily)

# Count the number of flagged students
persistence_straight_line_count <- sum(df$persistence_straight_line_flag == "Flagged")

# --------------------------------------
# Identifying Students Flagged in Multiple Categories
# --------------------------------------

# Count students flagged in any two out of three categories
two_out_of_three_flagged <- sum(
  (df$perception_straight_line_flag == "Flagged" & df$feeling_straight_line_flag == "Flagged" & df$persistence_straight_line_flag != "Flagged") |
    (df$perception_straight_line_flag == "Flagged" & df$persistence_straight_line_flag == "Flagged" & df$feeling_straight_line_flag != "Flagged") |
    (df$feeling_straight_line_flag == "Flagged" & df$persistence_straight_line_flag == "Flagged" & df$perception_straight_line_flag != "Flagged")
)

# Count students flagged in all three categories
all_three_flagged <- sum(
  df$perception_straight_line_flag == "Flagged" & 
    df$feeling_straight_line_flag == "Flagged" & 
    df$persistence_straight_line_flag == "Flagged"
)

# --------------------------------------
# Saving Updated Dataset with Flagging Columns
# --------------------------------------

# Remove temporary list-columns used for straight-lining checks
df <- df %>%
  select(-persistence_responses, -filtered_responses)

# Define output file path
output_file <- "data/private/processed/2022/pisa2022_cleaned_15_flagging_procedures.csv"

# Save cleaned dataset (both CSV and RDS)
save_cleaned(df, output_file)

# Completion Messages
cat("Updated dataset with straight-lining flags saved to:", output_file, "\n")

# Updated dataset review
table(df$covid_inconsistency_flag, useNA = "ifany")
cat("Total students flagged for extreme straight-lining in teacher perception variables:", perception_straight_line_count, "\n")
cat("Total students flagged for extreme straight-lining in student feelings variables:", feeling_straight_line_count, "\n")
cat("Total students flagged for extreme straight-lining in persistence variables:", persistence_straight_line_count, "\n")
cat("Total students flagged in exactly two out of three categories:", two_out_of_three_flagged, "\n")
cat("Total students flagged in all three categories:", all_three_flagged, "\n")
