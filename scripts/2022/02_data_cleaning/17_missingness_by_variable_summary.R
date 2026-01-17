# Load necessary libraries
library(dplyr)
library(readr)

# Define file path
data_path <- "data/private/processed/2022/pisa2022_cleaned_8_recalculated_ict_distress_online.csv"

# Load dataset
df <- read_csv(data_path, show_col_types = FALSE)

# -----------------------------------------------
# 🔎 Helper function: Select variables between two points
select_vars_between <- function(start_var, end_var, var_names) {
  start_pos <- which(var_names == start_var)
  end_pos <- which(var_names == end_var)
  if (length(start_pos) == 1 && length(end_pos) == 1) {
    return(var_names[start_pos:end_pos])
  } else {
    stop("Start or end variable not found!")
  }
}

# -----------------------------------------------
# 🗂️ Define variable categories dynamically
var_names <- names(df)

variable_categories <- list(
  # Example groups based on your logic:
  
  student_questionnaire_vars = select_vars_between("student_grade_level", "effort_accurate_pisa", var_names),
  
  ict_questionnaire_vars = select_vars_between("school_use_desktop_laptop", "can_represent_solution_steps", var_names),
  
  student_derived_vars = select_vars_between("test_effort_actual", "escs_index", var_names),
  
  ict_derived_vars = select_vars_between("ict_at_school", "ict_self_efficacy", var_names),
  
  school_questionnaire_vars = select_vars_between("community_type", "encourage_pisa_effort", var_names),
  
  school_derived_vars = select_vars_between("school_type_derived", "digital_learning_preparedness", var_names)
)

# -----------------------------------------------
# Function to filter only existing variables in df
filter_existing_vars <- function(var_list, df) {
  intersect(var_list, names(df))
}

# -----------------------------------------------
# Function to count occurrences of a specific value (98, 99, or NA)
count_specific_code <- function(df, code_value) {
  results <- list()
  
  for (category_name in names(variable_categories)) {
    variable_list <- variable_categories[[category_name]]
    existing_vars <- filter_existing_vars(variable_list, df)
    
    if (length(existing_vars) > 0) {
      df_subset <- df %>% select(all_of(existing_vars))
      
      counts <- if (code_value == "NA") {
        df_subset %>%
          summarise(across(everything(), ~ sum(is.na(.)), .names = "{.col}")) %>%
          pivot_longer(everything(), names_to = "Variable", values_to = "Count")
      } else {
        df_subset %>%
          summarise(across(everything(), ~ sum(. == code_value, na.rm = TRUE), .names = "{.col}")) %>%
          pivot_longer(everything(), names_to = "Variable", values_to = "Count")
      }
      
      counts <- counts %>%
        arrange(desc(Count)) %>%
        slice_head(n = 30) %>%
        mutate(Category = category_name, Code = as.character(code_value)) %>%
        select(Category, Code, Variable, Count)
      
      results[[category_name]] <- counts
    }
  }
  
  bind_rows(results)
}

# -----------------------------------------------
# 💾 Function to create and save the files
save_code_counts <- function(code_value, filename) {
  result <- count_specific_code(df, code_value)
  write_csv(result, paste0("data/private/metadata/2022/", filename))
}

# -----------------------------------------------
# 🚀 Generate output files for 98, 99, and NA
save_code_counts(98, "pisa2022_top30_98_counts.csv")
save_code_counts(99, "pisa2022_top30_99_counts.csv")
save_code_counts("NA", "pisa2022_top30_NA_counts.csv")

cat("✅ CSV files successfully created:\n",
    "- pisa2022_top30_98_counts.csv\n",
    "- pisa2022_top30_99_counts.csv\n",
    "- pisa2022_top30_NA_counts.csv\n")


# Print completion message
cat("✅ CSV files successfully created:\n",
    "- pisa2022_top30_98_counts.csv\n",
    "- pisa2022_top30_99_counts.csv\n",
    "- pisa2022_top30_NA_counts.csv\n")