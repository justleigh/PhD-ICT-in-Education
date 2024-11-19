# Load necessary libraries
library(dplyr)
library(readr)
library(janitor)

# Function to dynamically load Stage 1 cleaned PISA data for a given year
load_cleaned_pisa_data <- function(year) {
  csv_path <- paste0("data/processed/", year, "/pisa", year, "_cleaned_stage1.csv")
  pisa_data <- read_csv(csv_path)
  return(pisa_data)
}

# List of PISA years to process
years <- c(2000, 2003, 2006, 2009, 2012, 2015, 2018, 2022)

# Loop through each year, load the Stage 1 cleaned data, clean further, and save
for (year in years) {
  # Load Stage 1 cleaned data
  pisa_data <- load_cleaned_pisa_data(year)
  
  # Step 1: Address Remaining Missing Data
  # Remove variables with more than 50% missing data
  missing_data_summary <- sapply(pisa_data, function(x) sum(is.na(x)) / length(x) * 100)
  missing_data_summary <- data.frame(Variable = names(missing_data_summary),
                                     Missing_Percentage = missing_data_summary)
  
  high_missing_variables <- missing_data_summary %>%
    filter(Missing_Percentage > 50) %>%
    pull(Variable)
  
  pisa_data <- pisa_data %>% select(-one_of(high_missing_variables))
  
  # Impute missing values for numeric variables using median
  numeric_vars <- sapply(pisa_data, is.numeric)
  pisa_data[numeric_vars] <- lapply(pisa_data[numeric_vars], function(x) {
    ifelse(is.na(x), median(x, na.rm = TRUE), x)
  })
  
  # Impute missing values for categorical variables using mode
  categorical_vars <- sapply(pisa_data, is.character)
  pisa_data[categorical_vars] <- lapply(pisa_data[categorical_vars], function(x) {
    ifelse(is.na(x), names(sort(table(x), decreasing = TRUE))[1], x)
  })
  
  # Step 2: Standardize Variable Names
  pisa_data <- janitor::clean_names(pisa_data)
  
  # Step 3: Handle Outliers
  # Use interquartile range (IQR) to detect and remove outliers in numeric variables
  numeric_vars <- sapply(pisa_data, is.numeric)
  for (var in names(pisa_data)[numeric_vars]) {
    Q1 <- quantile(pisa_data[[var]], 0.25, na.rm = TRUE)
    Q3 <- quantile(pisa_data[[var]], 0.75, na.rm = TRUE)
    IQR <- Q3 - Q1
    pisa_data <- pisa_data %>%
      filter(pisa_data[[var]] >= (Q1 - 1.5 * IQR) & pisa_data[[var]] <= (Q3 + 1.5 * IQR))
  }
  
  # Step 4: Save Cleaned Stage 2 Data
  output_path <- paste0("data/processed/", year, "/pisa", year, "_cleaned_stage2.csv")
  write_csv(pisa_data, output_path)
  
  # Print a message confirming the process for each year
  cat(sprintf("Year %d: Removed %d variables with >50%% missing data. Cleaned data saved to %s\n",
              year, length(high_missing_variables), output_path))
}